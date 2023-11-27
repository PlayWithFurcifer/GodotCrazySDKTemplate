extends Node

signal ad_started
signal ad_finished
signal ad_error
signal ad_done # finished or error
signal adblock_result # error, result

var SDK = null

var adStartedCallback = JavaScript.create_callback(self, "adStarted")
var adErrorCallback = JavaScript.create_callback(self, "adError")
var adFinishedCallback = JavaScript.create_callback(self, "adFinished")
var adCallbacks

var adblockCallback

func hasSDK() -> bool:
	return SDK != null

func _ready() -> void:
	if not OS.has_feature("crazygames"): return
	
	var window = JavaScript.get_interface("window")
	SDK = window.CrazyGames.SDK

	adCallbacks = JavaScript.create_object("Object")
	adCallbacks["adFinished"] = adFinishedCallback
	adCallbacks["adError"] = adErrorCallback
	adCallbacks["adStarted"] = adStartedCallback
	
	adblockCallback = JavaScript.create_callback(self, "adblockResult")

# ad module

func adStarted(args):
	print("[Godot] adStarted callback")
	emit_signal("ad_started")

func adError(error):
	print("[Godot] adError callback")
	emit_signal("ad_error", error)
	emit_signal("ad_done")

func adFinished(args):
	print("[Godot] adFinished callback")
	emit_signal("ad_finished")
	emit_signal("ad_done")

func midgameAd():
	if not SDK: return
	SDK.ad.requestAd("midgame", adCallbacks)

func rewardedAd():
	if not SDK: return
	SDK.ad.requestAd("rewarded", adCallbacks)


func detectAdblock():
	if not SDK: return
	SDK.ad.hasAdblock(adblockCallback)

func adblockResult(args):
	var error = args[0]
	var result = args[1]
	emit_signal("adblock_result", error, result)

# game module

func gameplayStart():
	if not SDK: return
	SDK.game.gameplayStart()

func gameplayStop():
	if not SDK: return
	SDK.game.gameplayStop()

func happytime():
	if not SDK: return
	SDK.game.happytime()

func gameLoadingStart():
	if not SDK: return
	SDK.game.sdkGameLoadingStart()

func gameLoadingStop():
	if not SDK: return
	SDK.game.sdkGameLoadingStop()

# banner module

func requestBanner(width : int, height : int):
	if not SDK: return
	var params = JavaScript.create_object("Object")
	params["id"] = "banner-container"
	params["width"] = width
	params["height"] = height
	SDK.banner.requestBanner(params)

func requestResponsiveBanner():
	if not SDK: return
	SDK.banner.requestResponsiveBanner("responsive-banner-container")

func clearAllBanners():
	if not SDK: return
	SDK.banner.clearAllBanners()
