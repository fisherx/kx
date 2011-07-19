/ generate data for rdb demo

sn:2 cut (
 `AMD;"ADVANCED MICRO DEVICES";
 `AIG;"AMERICAN INTL GROUP INC";            
 `AAPL;"APPLE INC COM STK";
 `DELL;"DELL INC";
 `DOW;"DOW CHEMICAL CO";
 `GOOG;"GOOGLE INC CLASS A";
 `HPQ;"HEWLETT-PACKARD CO";
 `INTC;"INTEL CORP";
 `IBM;"INTL BUSINESS MACHINES CORP";
 `MSFT;"MICROSOFT CORP")
 
s:first each sn
n:last each sn
p:84 27 33 12 20 18 36 84 42 72 / price
m:" ABHILNORYZ" / mode
c:" 89ABCEGJKLNOPRTWZ" / cond
e:"NONNONONNN" / ex
/ init.q

cnt:count s
pi:acos -1
gen:{exp 0.0015 * normalrand x} / prices
normalrand:{(cos 2 * pi * x ? 1f) * sqrt neg 2 * log x ? 1f}
randomize:{value "\\S ",string "i"$0.8*.z.p%1000000000}
rnd:{0.01*floor 0.5+x*100}
vol:{10+`int$x?90}

randomize[]

/ =========================================================
/ generate a batch of prices
/ qx index, qb/qa margins, qp price, qn position
batch:{
  d:gen x;
  qx::x?cnt;
  qb::rnd x?1.0;
  qa::rnd x?1.0;
  n:where each qx=/:til cnt;
  s:p*prds each d n;
  qp::x#0.0;                  
  (qp raze n):rnd raze s;
  p::last each s;
  qn::0}
/ gen feed for ticker plant

len:10000
batch len

maxn:10 / max trades per tick
qpt:5   / avg quotes per trade

/ =========================================================
t:{
 if[not (qn+x)<count qx;batch len];
 i:qx n:qn+til x;qn+:x;
 sp:x?0b;
 (s i;qp n;`int$x?99;sp;x?c;e i)}

q:{
 if[not (qn+x)<count qx;batch len];
 i:qx n:qn+til x;p:qp n;qn+:x;
 (s i;p-qb n;p+qa n;vol x;vol x;x?m;e i)}

h:hopen `::5010

/ h("upd";`quote;q 15);
/ h("upd";`trade;t 5);

/ =========================================================
.z.ts:{(neg h)$[rand 2;
 ("upd";`trade;t 1+rand maxn);
 ("upd";`quote;q 1+rand qpt*maxn)]}