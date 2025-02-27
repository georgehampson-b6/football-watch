using Toybox.Application;
using Toybox.Communications;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Attention;

class WebRequestApp extends Application.AppBase {
    var activeView;
    var requestTimer;

    function initialize() {
        Application.AppBase.initialize();
    }

    function onStart(state) {
        System.println("🚀 App has started!");
        activeView = new WebRequestView();
        // Display the initial view
        WatchUi.pushView(activeView, new WatchUi.InputDelegate(), WatchUi.SLIDE_IMMEDIATE);

        // Start the request timer (every 200 milliseconds)
        requestTimer = new Timer.Timer();
        requestTimer.start(method(:makeRequest), 200, true);
    }

    function getInitialView() {
        return [activeView];
    }

    // Perform the HTTP GET request
    function makeRequest() as Void {
        System.println("📡 Sending request to server...");

        var url = "http://192.168.137.1:8888";

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :timeout => 2000,
            :disableSslVerify => true,
            :headers => {
                "Cache-Control" => "no-cache, no-store, must-revalidate",
                "Pragma" => "no-cache",
                "Expires" => "0"
            }
        };

        Communications.makeWebRequest(url, {}, options, method(:onReceive));
    }

    // Handle the HTTP response
    function onReceive(responseCode as Toybox.Lang.Number, data as Toybox.Lang.Dictionary or Toybox.Lang.String or Null) as Void {
		System.println("📡 Response Code: " + responseCode);

		if (responseCode == 200 && data != null) {
			System.println("✅ Request Successful!");
			System.println("📜 Response Data: " + data);

			var responseDict = data as Toybox.Lang.Dictionary;
			if (responseDict != null && responseDict.hasKey("status")) {
				var status = responseDict.get("status") as Toybox.Lang.String;
				System.println("🔍 Parsed Status: '" + status + "'");

				// 🔹 Only update the image when the status changes
				activeView.updateImage(status);
			}
		}
	}
}

class WebRequestView extends WatchUi.View {
    var goalImage;
    var noGoalImage;
    var noDataImage;
    var showGoal = false;
    var showNoGoal = false;
    var showNoData = false;
    var lastStatus = "none"; // 🆕 Track last displayed status

    function initialize() {
        View.initialize();
        goalImage = WatchUi.loadResource(Rez.Drawables.goalImage) as Graphics.Bitmap;
        noGoalImage = WatchUi.loadResource(Rez.Drawables.noGoalImage) as Graphics.Bitmap;
        noDataImage = WatchUi.loadResource(Rez.Drawables.noDataImage) as Graphics.Bitmap;
    }

    function onUpdate(dc as Graphics.Dc) {
		System.println("🖥 Updating Screen...");
		if (showGoal && goalImage != null) {
			System.println("🎯 Drawing Goal Image");
			dc.drawBitmap((dc.getWidth() - goalImage.getWidth()) / 2,
						  (dc.getHeight() - goalImage.getHeight()) / 2,
						  goalImage);
		} else if (showNoGoal && noGoalImage != null) {
			System.println("🚫 Drawing No-Goal Image");
			dc.drawBitmap((dc.getWidth() - noGoalImage.getWidth()) / 2,
						  (dc.getHeight() - noGoalImage.getHeight()) / 2,
						  noGoalImage);
		} else if (showNoData && noDataImage != null) {
			System.println("❌ Drawing No-Data Image");
			dc.drawBitmap((dc.getWidth() - noDataImage.getWidth()) / 2,
						  (dc.getHeight() - noDataImage.getHeight()) / 2,
						  noDataImage);
		} else {
			System.println("⚠️ No image is set to display!");
		}
	}


    function updateImage(newStatus as Toybox.Lang.String) {
        if (newStatus == lastStatus) {
            // 🔹 No change in status, keep current image
            return;
        }

        // 🔹 Update lastStatus and change image only if needed
        lastStatus = newStatus;
        
        if (newStatus.equals("goal")) {
            var vibePattern = [ new Attention.VibeProfile(255, 500) ]; // 100% intensity for 500 ms
            Attention.vibrate(vibePattern);
			showGoal = true;
            showNoGoal = false;
            showNoData = false;
        } else if (newStatus.equals("no-goal")) {
            showGoal = false;
            showNoGoal = true;
            showNoData = false;
        } else {
            showGoal = false;
            showNoGoal = false;
            showNoData = true;
        }

        // 🔹 Refresh screen only when the status changes
        WatchUi.requestUpdate();
    }
}