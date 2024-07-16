% ------------------------Main program---------------------------
% This programmer include following steps:
% 1 - imread image
% 2 - contour pixels recognition
% 3 - extract control points
% 4 - B-spline fitting
% 5 - coordinate transformation
% 6 - error verification

%% 1 - imread image
pixels = rgb2gray(imread('address')); % image from software origin (see simulated_examples.m)
pixels = histeq(pixels,2); % image binaryzation
pixels = imrotate(pixels,180); 
% imshow(pixels)

row = size(pixels,1);
col = size(pixels,2);
x1 = zeros(2,row*col);
count = 1;
for i = 3:col-3 % Remove boundary line pixels
    
    for j = 3:row-3
        
        if(pixels(j,i) ~= 0)
                    
            continue
         
        else
            
            x1(1,count) = i;
            x1(2,count) = j;
            count = count + 1;

        end
    end
end

x1(:,count:end) = [];
x1(1,:) = x1(1,:) - min(x1(1,:));
x1(2,:) = x1(2,:) - min(x1(2,:)); 

%% 2 - contour pixels recognition
[bnode_idx,empty_set] = boundaryNodeNumber(x1);

%% 3 - extract control points
bump_idx = find(empty_set == 4 | empty_set >4); % extract convex pixels
Tdent_idx = find(empty_set <3); % extract concave pixels
L = 2; % tolerance value
dent_idx = []; 
for i = 1:length(Tdent_idx)
    
    % 找S1,S2
    count = 0;
    while(true)

        jug_S1 = find(bump_idx==Tdent_idx(i)-1,1);
        jug_S2 = find(bump_idx==Tdent_idx(i)+1,1);
        if(isempty(jug_S1)&&isempty(jug_S2))
            
            count = count + 1; 
            
            if(count >L)
                
                dent_idx = [dent_idx, Tdent_idx(i)];
                break
            end
        else
            break
        end
    end
end

control_idx = sort([bump_idx,dent_idx]); % control points


%% 4 - B-spline fitting
cubic B-spline
cx = x1(1,bnode_idx(control_idx));
cy = x1(2,bnode_idx(control_idx)); % the coordinates of control points

cxx = [2*cx(1)-cx(2),cx,cx(1),2*cx(1)-cx(end)]; 
cyy = [2*cy(1)-cy(2),cy,cy(1),2*cy(1)-cy(end)]; % 添加两个控制点保证过起点和末点

u = [];
v = []; % the point coordinates on cubic B-spline curve

for i=1:length(cxx)-3
    
    p0 = [cxx(i),cyy(i)];
    p1 = [cxx(i+1),cyy(i+1)];
    p2 = [cxx(i+2),cyy(i+2)];
    p3 = [cxx(i+3),cyy(i+3)];
    
    t = 0:0.01:1;
    
    a0 = (1-t).^3/6;
    a1 = (3*t.^3-6*t.^2+4)/6;
    a2 = (-3*t.^3+3*t.^2+3*t+1)/6;
    a3 = t.^3/6;
    
    u = [u,p0(1)*a0 + p1(1)*a1 + p2(1)*a2 + p3(1)*a3];
    v = [v,p0(2)*a0 + p1(2)*a1 + p2(2)*a2 + p3(2)*a3];
    
end


%% 5 - coordinate transformation
% the world coordinate (x0,y0)=(-16,4) is selected as reference point
% the pixel coordinate (u0,v0) at different image resolution need to confirmed

% % R=246×205 
% % (u0,v0)=[0 148]
% % pps_u：m/32   pps_v：[123 164] - [123 0]/22
% 
% % R=489×408
% % (u0,v0)=[0 295]  
% % pps_u：m/32   pps_v：[245 320] - [245 0]/22
% 
% % R=704×586
% % (u0,v0)=[0 425]  
% % pps_u：m/32   pps_v：[352 456] - [352 0]/22
% 
% % R=879×732
% % (u0,v0)=[0 531]  
% % pps_u：m/32   pps_v：[440 569] - [440 0]/22
% 
% % R=1172×976
% % (u0,v0)=[0 708] 
% % ppx_u：m/32   pps_v：[586 756] - [586 0]/22
% 
% % R=1756×1462
% % (u0,v0)=[0 1061] 
% % ppx_u：m/32   pps_v：[878 1128] - [878 0]/22
% 
% % R=2019×1683
% % (u0,v0)=[0 1222] 
% % ppx_u：m/32   pps_v：[1009 1295] - [1009 0]/22
% 
% % R=4036×3366
% % (u0,v0)=[0 2443]
% % ppx_u：m/32   pps_v：[2018 2581] - [2018 0]/22

m = max(x1(1,:))-min(x1(1,:));
pps_x = m/32;
pps_y = 2581/22; % R=4036×3366

trans_x = (u)/pps_x - 16;
trans_y = (v-2443)/pps_y + 4; % transformed coordinate 


%% 6 - error verification
xe = [];
ye = []; % error evaluation points(the first point of each cubic B-spline curve segment)
i=51;
while(true)

    xe = [xe trans_x(i)];
    ye = [ye trans_y(i)]; 
    i = i + 101;
    if(i>length(u))
        break
    end
end

t1 = asin(nthroot(xe/16,3)); 
delta_y = [];
for i=1:length(t1)
    if t1(i)>0
        t2 = pi-t1(i);
    else 
        t2 = -pi-t1(i);
    end
    t = [t1(i) t2];
    delta_y = [delta_y,min(abs(ye(i)-(13*cos(t)-5*cos(2*t)-2*cos(3*t)-cos(4*t))))];
end

rmse = sqrt(mean(delta_y.^2)); % RMSE
