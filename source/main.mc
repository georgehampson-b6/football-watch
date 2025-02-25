using Toybox.Application;
using Toybox.Communications;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Graphics;
using Toybox.Lang;

class WebRequestApp extends Application.AppBase {
    var activeView; // ✅ Store active view reference
    function initialize() {
        Application.AppBase.initialize();
    }

    function onStart(state) {
        activeView = new WebRequestView(); // ✅ Create and store view
        var timer = new Timer.Timer();
        timer.start(method(:makeRequest), 1000, true);
    }

    function makeRequest() as Void {
        var url = "https://postman-echo.com/get"; // ✅ Test API

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,      
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON // ✅ Expect JSON
        };

        Communications.makeWebRequest(url, {}, options, method(:onReceive));
    }

    function onReceive(responseCode as Toybox.Lang.Number, data as Toybox.Lang.Dictionary or Toybox.Lang.String or Null) as Void {
        System.println("📡 Response Code: " + responseCode);

        if (responseCode == 200) {
            System.println("✅ Request Successful!");

            // ✅ Use stored view reference
            if (activeView != null) {
                activeView.showGoalImage();
            }
        } else {
            System.println("⚠️ Request Failed! Response Code: " + responseCode);
        }
    }

    function getInitialView() {
        return [ activeView ]; // ✅ Return the stored view
    }
}

class WebRequestView extends WatchUi.View {
    var goalImage;
    var showGoal = false;

    function initialize() {
        View.initialize();
        goalImage = Application.loadResource(Rez.Drawables.goalImage) as Graphics.Bitmap;
    }

    function onUpdate(dc as Graphics.Dc) {
        dc.clear();

        if (showGoal && goalImage != null) {
            dc.drawBitmap((dc.getWidth() - goalImage.getWidth()) / 2,
                          (dc.getHeight() - goalImage.getHeight()) / 2,
                          goalImage);
        }
    }

    function showGoalImage() {
        showGoal = true;
        WatchUi.requestUpdate();
    }
}