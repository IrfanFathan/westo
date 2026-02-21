#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>

/* ================= WIFI CONFIG ================= */
const char* sta_ssid = "*********;
const char* sta_password = "******";

const char* ap_ssid = "Westo_ESP32";
const char* ap_password = "12345678";// ESP32 hotspot password


/* ================= SERVER ====================== */
WebServer server(80);

/* ================= SYSTEM DATA ================= */
int wasteLevel = 50;
bool lastUpdatedFromMobile = false;
unsigned long lastUpdateTime = 0;

/* ================= HTML DASHBOARD ============== */
const char* htmlPage = R"rawliteral(
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Westo Inventory Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<style>
:root{
 --primary:#2563eb;
 --bg:#f4f6f9;
 --card:#ffffff;
 --success:#22c55e;
 --danger:#ef4444;
 --muted:#6b7280;
}

body{
 margin:0;
 font-family:system-ui, sans-serif;
 background:var(--bg);
}

header{
 background:var(--primary);
 color:white;
 padding:18px;
 font-size:20px;
 font-weight:600;
}

.container{
 padding:16px;
 display:grid;
 grid-template-columns:repeat(auto-fit,minmax(280px,1fr));
 gap:16px;
}

.card{
 background:var(--card);
 border-radius:14px;
 padding:16px;
 box-shadow:0 10px 25px rgba(0,0,0,.08);
}

.card h3{
 margin:0 0 12px;
 font-size:16px;
}

.stat{
 display:flex;
 justify-content:space-between;
 margin-bottom:8px;
 color:var(--muted);
}

.badge{
 padding:4px 10px;
 border-radius:12px;
 font-size:13px;
 color:white;
}

.online{background:var(--success);}
.offline{background:var(--danger);}

.progress{
 height:14px;
 background:#e5e7eb;
 border-radius:10px;
 overflow:hidden;
}

.progress-bar{
 height:100%;
 background:linear-gradient(90deg,#22c55e,#16a34a);
 width:0%;
 transition:.4s;
}

input[type=range]{
 width:100%;
 margin-top:12px;
}

button{
 width:100%;
 padding:12px;
 background:var(--primary);
 border:none;
 color:white;
 border-radius:10px;
 font-size:15px;
 margin-top:12px;
}

.notice{
 margin-top:10px;
 padding:10px;
 border-radius:10px;
 background:#ecfeff;
 color:#0369a1;
 display:none;
 font-size:14px;
}
</style>
</head>

<body>

<header>Westo • Smart Waste Dashboard</header>

<div class="container">

<div class="card">
 <h3>Network Status</h3>
 <div class="stat">
  <span>Wi-Fi</span>
  <span id="wifi" class="badge offline">Checking</span>
 </div>
 <div class="stat">
  <span>Connected Devices</span>
  <span id="clients">0</span>
 </div>
</div>

<div class="card">
 <h3>Waste Level</h3>
 <div class="stat">
  <span>Current Level</span>
  <span id="levelText">--%</span>
 </div>

 <div class="progress">
  <div class="progress-bar" id="progress"></div>
 </div>

 <input type="range" min="0" max="100" id="slider">
 <button onclick="updateWaste()">Update Waste Level</button>

 <div class="notice" id="notice">
  🔔 Waste level updated from mobile device
 </div>
</div>

</div>

<script>
function loadStatus(){
 fetch('/status')
 .then(r=>r.json())
 .then(d=>{
   document.getElementById('clients').innerText=d.connectedClients;
   document.getElementById('levelText').innerText=d.wasteLevel+"%";
   document.getElementById('progress').style.width=d.wasteLevel+"%";
   document.getElementById('slider').value=d.wasteLevel;

   let wifi=document.getElementById('wifi');
   if(d.isConnected){
     wifi.innerText="Connected";
     wifi.className="badge online";
   }else{
     wifi.innerText="Not Connected";
     wifi.className="badge offline";
   }

   if(d.mobileUpdate){
     document.getElementById('notice').style.display="block";
     setTimeout(()=>{document.getElementById('notice').style.display="none";},3000);
   }
 });
}

function updateWaste(){
 let val=document.getElementById('slider').value;
 fetch('/update?level='+val);
}

setInterval(loadStatus,2000);
</script>

</body>
</html>
)rawliteral";

/* ================= HELPERS ===================== */
bool isWiFiConnected(){
return WiFi.status()==WL_CONNECTED;
}

/* ================= API HANDLERS ================= */
void handleRoot(){
server.send(200,"text/html",htmlPage);
}

void handleStatus(){
StaticJsonDocument<256> doc;
doc["wasteLevel"]=wasteLevel;
doc["isConnected"]=isWiFiConnected();
doc["connectedClients"]=WiFi.softAPgetStationNum();
doc["mobileUpdate"]=lastUpdatedFromMobile;

lastUpdatedFromMobile=false; // auto-clear

String res;
serializeJson(doc,res);
server.send(200,"application/json",res);
}

void handleUpdate(){
if(server.hasArg("level")){
wasteLevel=constrain(server.arg("level").toInt(),0,100);
lastUpdatedFromMobile=true;
lastUpdateTime=millis();
}
server.send(200,"text/plain","OK");
}

/* ================= SETUP ======================= */
void setup(){
Serial.begin(115200);

WiFi.mode(WIFI_AP_STA);
WiFi.softAP(ap_ssid,ap_password);
WiFi.begin(sta_ssid,sta_password);

server.on("/",handleRoot);
server.on("/status",handleStatus);
server.on("/update",handleUpdate);

server.begin();
}

/* ================= LOOP ======================== */
void loop(){
server.handleClient();
}
