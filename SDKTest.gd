extends Control

onready var debugLabel = $"%DebugLabel"
onready var bannerSizesList = $BannerSizes

var bannerSize = "300x250"

func logText(text : String) -> void:
	debugLabel.text += "\n" + text

func _ready() -> void:
	bannerSizesList.add_item("Responsive")
	bannerSizesList.add_item("728x90")
	bannerSizesList.add_item("300x250")
	bannerSizesList.add_item("320x50")
	bannerSizesList.add_item("468x60")
	bannerSizesList.add_item("320x100")
	bannerSizesList.select(2)
	
	if CrazySDK.hasSDK():
		logText("SDK initialized!")
		CrazySDK.connect("ad_started", self, "adStarted")
		CrazySDK.connect("ad_finished", self, "adFinished")
		CrazySDK.connect("ad_error", self, "adError")
		CrazySDK.connect("adblock_result", self, "adblockResult")
	else:
		logText("SDK not initialized")
		
func adStarted() -> void:
	logText("ad started")

func adFinished() -> void:
	logText("ad finished")
	
func adError(error) -> void:
	logText("ad error")
	if error is String:
		logText(error)

func _on_MidgameAdButton_pressed() -> void:
	CrazySDK.midgameAd()
	logText("Requesting midgame ad...")

func _on_RewardedAdButton_pressed() -> void:
	CrazySDK.rewardedAd()
	logText("Requesting rewarded ad...")

func _on_HappytimeButton_pressed() -> void:
	CrazySDK.happytime()
	logText("Requesting happytime...")

func _on_BannerSizes_item_selected(index: int) -> void:
	bannerSize = bannerSizesList.get_item_text(index)
	
func _on_BannerButton_pressed() -> void:
	if bannerSize == "Responsive":
		CrazySDK.requestResponsiveBanner()
		logText("Requesting responsive banner...")
	
	else:
		var size = bannerSize.split("x")
		CrazySDK.requestBanner(int(size[0]), int(size[1]))
		logText("Requesting banner of size %s..." % bannerSize)

func _on_ClearBannerButton_pressed() -> void:
	CrazySDK.clearAllBanners()
	logText("Banners cleared.")

func adblockDetection():
	CrazySDK.detectAdblock()
	logText("Detecting adblock...")

func adblockResult(error, result):
	if error:
		logText("Arror during adblock detection.")
	if result:
		logText("User is using an adblocker")
	else:
		logText("User is NOT using an adblocker")

func _on_GameplayButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		CrazySDK.gameplayStart()
		$GameplayButton.text = "Stop gameplay"
	else:
		CrazySDK.gameplayStop()
		$GameplayButton.text = "Start gameplay"


func _on_LoadingButton_pressed() -> void:
	CrazySDK.gameLoadingStart()
	$LoadingButton.text = "Loading..."
	var tween = create_tween()
	tween.tween_property($ProgressBar, "value", 100.0, 3).from(0.0)
	tween.tween_callback(self, "onLoadingFinished")

func onLoadingFinished():
	CrazySDK.gameLoadingStop()
	$LoadingButton.text = "Start loading"
