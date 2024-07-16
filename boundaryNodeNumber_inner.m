% -------------------- contour pixels recognition -----------------------
% used for inner contour

function [bnode_idx,dir_set,empty_set] = boundaryNodeNumber_inner(node_xy)

node_x = node_xy(1,:);
node_y = node_xy(2,:);

pixel = unique(node_x);
spacing = pixel(2) - pixel(1);

startPtX = 668;
startPtY = 870; % select the starting point position
% The point with the smallest x coordinate and the largest y coordinate on inner boundary
bnode_idx = find(node_x==startPtX&node_y==startPtY, 1);

d = spacing;
dir = [d,0;d,-d;
       0,-d;-d,-d;
       -d,0;-d,d;
       0,d;d,d];

dirNum = 1;

dir_set = [];
empty_set = [];

while(true)
    
    
    searchPtX = startPtX + dir(dirNum,1);
    searchPtY = startPtY + dir(dirNum,2);
    
    searchIdx = find(node_x==searchPtX&node_y==searchPtY, 1);
   
    if(~isempty(searchIdx))
    
        if(searchIdx == bnode_idx(1))

            count = 0;
            for i=1:8

                X = startPtX + dir(i,1);
                Y = startPtY + dir(i,2);

                Idx = find(node_x==X&node_y==Y, 1);
                if(isempty(Idx))

                   count = count + 1; 

                end
            end

            empty_set = [empty_set count];
            
            break
            
        else

            if(~ismember(searchIdx,bnode_idx))
         
                bnode_idx = [bnode_idx searchIdx];
                
                dir_set = [dir_set dirNum];

                count = 0;
                for i=1:8

                    X = startPtX + dir(i,1);
                    Y = startPtY + dir(i,2);

                    Idx = find(node_x==X&node_y==Y, 1);
                    if(isempty(Idx))

                       count = count + 1; 
                       
                    end
                end
                
                empty_set = [empty_set count];
                
                
            end
            
            startPtX = searchPtX;
            startPtY = searchPtY;

            if(dirNum==8)
                dirNum = 2;
            elseif(dirNum==7)
                dirNum = 1;
            else
                dirNum = dirNum + 2;
            end
            
        end

    else
        
        if(dirNum==1)
            dirNum = 8;
        else
            dirNum = dirNum - 1;
        end
    end

end

