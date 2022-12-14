clear;
close all;

numBoids = 90;      % Number of boids to be simulated.
height = 200;       % Height of the world.
width = 250;        % Width of the world.
length = 250;        % length of the world.
iteration = 10000;    % Number of simulation times.
b_max_speed = 5;      % Maximum speed of boids.
central_sephere = 5;

% Create an array of Boid objects.
boids(numBoids) = Boid;

initialPts = readmatrix("Point Cloud Squence/90DronesRise.csv");
ptCld(:,:,1) = readmatrix("Point Cloud Squence/butterfly.csv");
ptCld(:,:,2) = readmatrix("Point Cloud Squence/cat.csv");
ptCld(:,:,3) = readmatrix("Point Cloud Squence/teapot.csv");

% Iniialize the boids with coordinate, and velocity.
h = plot3(0,0,0);
hold on;
xlim([0, length]);
ylim([0 width]);
zlim([0 height]);
    
arrows = [];

displalPlot = true;

collisions = 0;
for i = 1 : numBoids
    boids(i).coord = initialPts(i,:);
    boids(i).ID = i;
    boids(i).central_range = central_sephere;
    arrows(i) = arrow('Start',[0,0,0],'Stop',[0,0,0],'Length',0,'BaseAngle',0);
end

for k = 1:size(ptCld,3)
    % Initialize the boids with coordinate, and velocity.
    for i = 1 : numBoids
        boids(i).target = ptCld(i,:,k);
        boids(i).set_display(length, width, height);
        boids(i).set_max_speed(b_max_speed);
        boids(i).velocity = (boids(i).target - boids(i).coord) * b_max_speed/norm((boids(i).target - boids(i).coord));
        boids(i).arrived = false;
        boids(i).distTraveled = 0;
    end
    
    step = 0;
    record_arrived = zeros(numBoids, 1);
    speeds = [];
    arrived = zeros(numBoids, 1);
    gathered_center = zeros(numBoids, 1);
    speedWhileAvoiding = [];

    waypointslastStep = [];
    waypointsPerStep = [];
    count_arrived = 0;
    at_central = 0;

    % Simulating boids flying toward center
    while ~all(gathered_center) == 1
        
        step = step + 1;

        for i = 1 : numBoids
            if boids(i).removed
                gathered_center(i) = 1;
            end
            if boids(i).arrived
                if ~record_arrived(i)
                    arrived(i) = 1;
                    count_arrived = count_arrived + 1;
                    record_arrived(i) = step;
                    fprintf("Drone %d has arrived\n", i);
                end
            end
            
%             if (step == 1114)
%                 pause(0.1);
%             end
%     
            waypointslastStep(i,:) = boids(i).coord;
            [isColliding, avoidSpeed] = boids(i).move(boids, true);
            waypointsPerStep(i,:) = boids(i).coord;
            speed(i,step) = norm(boids(i).velocity);

            if ~gathered_center(i) && norm(boids(i).coord - [length/2, width/2, height/2]) < central_sephere
                gathered_center(i) = 1;
                at_central = at_central + 1;
            end
     
            if avoidSpeed
                speedWhileAvoiding = [speedWhileAvoiding, avoidSpeed];
            end
    
            if isColliding
                collisions = collisions + 1;
                fprintf("Collide! Times %d\n", collisions);
            end
        end
    
        
        fprintf("Step %d, %d has arrived, %d collisions, %d by central\n", step, count_arrived, collisions, at_central);
        if displalPlot
            for i = 1 : numBoids
    
                if gathered_center(i)
                    arrows(i) = arrow(arrows(i),'Start',waypointslastStep(i,:),'Stop',waypointsPerStep(i,:),'Length',3,'BaseAngle',20, 'Color', 'r');
                else
                    arrows(i) = arrow(arrows(i),'Start',waypointslastStep(i,:),'Stop',waypointsPerStep(i,:),'Length',3,'BaseAngle',20, 'Color', 'b');
                end
        %             fprintf("Drone %d dist To Target %f", i, norm(boids(i).coord - boids(i).target));
            end
    
            pause(0.000001);
        end
    end
        
    
    % Start the simulation.
    while ~all(arrived) == 1
    % while step < 100
        step = step + 1;

        % Simulation of boids flying to target from center of display.
        for i = 1 : numBoids
            if boids(i).arrived
                if ~record_arrived(i)
                    arrived(i) = 1;
                    count_arrived = count_arrived + 1;
                    record_arrived(i) = step;
                    fprintf("Drone %d has arrived\n", i);
                end
            end
    
    
            waypointslastStep(i,:) = boids(i).coord;
            [isColliding, avoidSpeed] = boids(i).move(boids, false);
            waypointsPerStep(i,:) = boids(i).coord;
            speed(i,step) = norm(boids(i).velocity);
     
            if avoidSpeed
                speedWhileAvoiding = [speedWhileAvoiding, avoidSpeed];
            end
    
            if isColliding
                collisions = collisions + 1;
                fprintf("Collide! Times %d", collisions);
            end
        end
    
        
        fprintf("Step %d, %d has arrived, %d collisions\n", step, count_arrived, collisions);
        if displalPlot
            for i = 1 : numBoids
    
                if boids(i).arrived
                    arrows(i) = arrow(arrows(i),'Start',waypointslastStep(i,:),'Stop',waypointsPerStep(i,:),'Length',3,'BaseAngle',20, 'Color', 'r');
                else
                    arrows(i) = arrow(arrows(i),'Start',waypointslastStep(i,:),'Stop',waypointsPerStep(i,:),'Length',3,'BaseAngle',20, 'Color', 'b');
                end
        %             fprintf("Drone %d dist To Target %f", i, norm(boids(i).coord - boids(i).target));
            end
    
            pause(0.000001);
        end
    
    end
    maxSpeeds = [];
    minSpeeds = [];
    avgSpeeds = [];
    for i = 1 : numBoids
        speedOfBoid = speed(i,1:record_arrived(i));
        maxSpeeds(i) = max(speedOfBoid);
        minSpeeds(i) = min(speedOfBoid);
        avgSpeeds(i) = mean(speedOfBoid);
    end
    
    fprintf("Max time: %d, Min Time: %d, Avg Time: %.2f; \n" + ...
        "Max Speed: %.2f, Min Speed: %.2f, Avg Speed: %f;\n" + ...
        "Max Speed while avoiding: %.2f, Min Speed while avoiding: %.2f, Avg Speed While Avoiding: %.2f\n..." + ...
        "Total Collision: %d\n", ...
        max(record_arrived), min(record_arrived), mean(record_arrived),...
        max(maxSpeeds), min(minSpeeds), mean(dot(avgSpeeds,record_arrived)/sum(record_arrived)),...
        max(speedWhileAvoiding), min(speedWhileAvoiding), mean(speedWhileAvoiding), ...
        collisions);
    
%     for i = 1 : numBoids
%         disp(boids(i).distTraveled/record_arrived(i));
%     end
end
