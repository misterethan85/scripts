BEGIN{
 IGNORECASE = 1;
 command = "wl scan 2> /dev/null ; wl scanresults 2> /dev/null";
 red = "\x1b[31m";              green = "\x1b[32m";
 greenback="\x1b[42m";          yellow = "\x1b[33m";
 cyan = "\x1b[36m";             blue = "\x1b[34m";
 blueback = "\x1b[44m";         white = "\x1b[37m";
 whiteback = "\x1b[47m";        reset = "\x1b[0m";
 underscore = "\x1b[4m";        clear = "\x1b[2J";
 home = "\x1b[0;0H";            erase2end = "\x1b[K";
 cName = white;                 cSignal = green;
 cNoise = red;                  cCaps = green;
 cStrengthLow = blue blueback;  cChannel = green;               
 cStrengthMed = white whiteback;
 cStrengthHi = green greenback;
 cStrengthAged = red;
  
 print clear;
 for(;;)
 {
  while (command|getline)
  {
  if(/^SSID/) { name = ;  rssi = ;noise= ; rssi=""; noise="";channel="";bssid="";caps=""}
  if(/^Mode/) {rssi = ;noise= ; channel =  }
  if(/^BSSID/) {bssid = ; caps = " "" "" "" "" "" " }
  if(/^Supported/) 
	{
	name[bssid] = name
	rssi[bssid] = rssi
	noise[bssid]= noise
	channel[bssid] = channel
	caps[bssid] = caps
	} 
  }
  close(command)
  printf home;
  ln = 0;
  print white " Name       BSSID  Signal Noise Channel Type";
  for (x in name)
  {
        {
        #arbitrary strength calc through trial and error... modify as you wish:
        sigstrength = ((rssi[x] - noise[x])*1.5) + ((rssi[x] +90)*1.5));
        if (sigstrength <1) sigstrength=0;
        cStrength = cStrengthLow;
        if(sigstrength>4) cStrength = cStrengthMed;
        if(sigstrength>7) cStrength = cStrengthHi;
        if(age[x]=0) cStrength = cStrengthAged;
        
        fmt = "%s%-15s %s%0"sigstrength"d "reset erase2end "\n    %s  %s%-4d %s%-4d %s%-4d %s%2s %s%10s "  reset erase2end "\n" erase2end "\n";
        printf fmt, cName,name[x],cStrength,0,x,cSignal,rssi[x],cNoise,noise[x],cChannel, channel[x],cCaps,caps[x]; 
        rssi[x] = "-1000 xxxx";
        ln++;
        }
  }  
  if (ln ==0) print red "No Results - Do you have wl scan capability? \nThis program depends on 'wl scan; wl scanresults' to run. Hit ctrl-c to stop."
  print erase2end;
 }
}
