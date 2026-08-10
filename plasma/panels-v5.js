// panels-v5: monitor đồng bộ CPU/RAM/GPU + net số, media, mini clock trên top bar;
// bottom floating + colorizer + clock giây dd/MM/yyyy, bỏ showdesktop
function set(p,k,v){ p[k]=v; }
function cfg(w,g,k,v){ w.currentConfigGroup=[g]; w.writeConfig(k,v); }

var out=[];
var panels_ = panels();

function buildTopContents(p){
  var ws=p.widgets(); for(var j=0;j<ws.length;j++) ws[j].remove();
  p.addWidget("org.kde.plasma.appmenu");
  p.addWidget("org.kde.plasma.marginsseparator");
  // media controls
  p.addWidget("org.kde.plasma.mediacontroller");
  p.addWidget("org.kde.plasma.marginsseparator");
  // 3 pie đồng bộ: CPU xanh dương, RAM xanh lá, GPU mauve
  var mons=[["org.kde.plasma.systemmonitor.cpu","cpu/all/usage","137,180,250"],
            ["org.kde.plasma.systemmonitor.memory","memory/physical/usedPercent","166,227,161"],
            ["org.kde.plasma.systemmonitor","gpu/gpu2/usage","203,166,247"]];
  for(var m=0;m<mons.length;m++){
    var w=p.addWidget(mons[m][0]);
    w.currentConfigGroup=["Appearance"];
    w.writeConfig("chartFace","org.kde.ksysguard.piechart");
    w.writeConfig("showTitle",false);
    w.writeConfig("showLegend",false);
    if(mons[m][0]==="org.kde.plasma.systemmonitor"){
      w.writeConfig("title","GPU");
      w.currentConfigGroup=["Sensors"];
      w.writeConfig("highPrioritySensorIds","[\"" + mons[m][1] + "\"]");
    }
    w.currentConfigGroup=["SensorColors"];
    w.writeConfig(mons[m][1],mons[m][2]);
    w.reloadConfig();
  }
  // network dạng SỐ (text-only): down + up
  var nw=p.addWidget("org.kde.plasma.systemmonitor.net");
  nw.currentConfigGroup=["Appearance"];
  nw.writeConfig("chartFace","org.kde.ksysguard.textonly");
  nw.writeConfig("showTitle",false);
  nw.currentConfigGroup=["Sensors"];
  nw.writeConfig("highPrioritySensorIds","[\"network/all/download\",\"network/all/upload\"]");
  nw.currentConfigGroup=["SensorColors"];
  nw.writeConfig("network/all/download","250,179,135");
  nw.writeConfig("network/all/upload","148,226,213");
  nw.reloadConfig();
  p.addWidget("org.kde.plasma.marginsseparator");
  // tray + volume + network
  var t=p.addWidget("org.kde.plasma.systemtray");
  cfg(t,"General","scaleIconsToFit",false);
  p.addWidget("org.kde.plasma.volume");
  p.addWidget("org.kde.plasma.networkmanagement");
  // mini clock: giây + dd/MM/yyyy
  var c=p.addWidget("org.kde.plasma.digitalclock");
  cfg(c,"Appearance","showSeconds",2);
  cfg(c,"Appearance","dateFormat","custom");
  cfg(c,"Appearance","customDateFormat","dd/MM/yyyy");
  cfg(c,"Appearance","dateDisplayFormat","besideTime");
  cfg(c,"Appearance","autoFontAndSize",false);
  cfg(c,"Appearance","fontSize",10);
  c.reloadConfig();
}

for(var i=0;i<panels_.length;i++){
  var p=panels_[i];
  if(p.location!=="top") continue;
  buildTopContents(p);
  out.push("top screen="+p.screen+" OK ("+p.widgets().length+" widget)");
}

// ---- bottom taskbar ----
for(var i=0;i<panels_.length;i++){
  var p=panels_[i];
  if(p.location!=="bottom") continue;
  set(p,"floating",true);
  var ws=p.widgets();
  for(var j=0;j<ws.length;j++){
    var w=ws[j];
    if(w.type==="org.kde.plasma.showdesktop"||w.type==="org.kde.plasma.minimizeall"){ w.remove(); continue; }
    if(w.type==="org.kde.plasma.digitalclock"){
      cfg(w,"Appearance","showSeconds",2);
      cfg(w,"Appearance","dateFormat","custom");
      cfg(w,"Appearance","customDateFormat","dd/MM/yyyy");
      w.reloadConfig();
    }
  }
  // Panel Colorizer đặt cuối
  p.addWidget("luisbocanegra.panel.colorizer");
  out.push("bottom screen="+p.screen+" floating+colorizer OK");
}
print(out.join(" | "));
