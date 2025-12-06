data1=readtable("sindy.csv");
t=data1.timestamp;
X=data1.sensor1;
Y=data1.sensor2;
dX=data1.vel1;
dY=data1.vel2;

save('experimental_data.mat','t','X','Y','dX','dY');
