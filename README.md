# LQR_control_Launch_vehicle
Stabilizing a launch vehicle model using LQR by finding the full state feedback gain and then simulating it from simulink to flightgear

-----

## LQR Controller (Linear Quadratic Controller)

LQR is an optimal control based on the state space representation of the system. Your state space model has vectors of states and inputs which control the overall system and for a perticular desired state to be reached, which can be controlled by multiple inputs provided, states are feedbacked with perticular LQR gains K, which are then again feedbacked as an input to the system. 

The A matrix in the state space representation is a matrix which actually represents the dynamics of the system and so stability of a system can be found out using this matrix by finding the eigenvalues of this matrix which directly gives the poles of the system. Introducing a full state LQR feedback changes the A matrix to (A - B.K), where B is the matrix associated with input and K is LQR gain. Thus clearly by optimizing K we can directly control the dynamics of closed loop system and thus can stabilize it. For checking the stability of this closed loop system, again find the eigenvalues of (A - B.K) which directly gives the value of the poles of the system.

  ![LQR_pic](https://user-images.githubusercontent.com/69386934/125062146-b5eb1f00-e0cb-11eb-8882-bf5e5a363954.png)
  ![LQR_cost](https://user-images.githubusercontent.com/69386934/125062631-3dd12900-e0cc-11eb-96ed-3881170e80a7.png)


Now it might be clear that the only main thing left here is how to calculate the LQR gain and how to give on what basis it should calculate it?

For this a special kind of cost function is used by LQR as shown above. Here x and u are states and inputs in the system and this equation is written for the general case of having n states and m inputs arranged in matrix form. Here the main part is the integrator part where for throughout the process time, it tries to calculate the area under state-v-time as well as input-v-time about the desired variables specified by weigths Q and R matrices. In this project Q and R were already specified but it can be tuned as per the requirements from the system. Q weight directly impacts the individual states of the system and R weight impacts the inputs. According to the value for each state or input in the weights, priorites are made or in other words for higher weight value for some states, it would be less of an importance for control purpose rather than those with lower valued weights. Here N is the interdependancy of inputs and staets while controlling, but in this project N=0 as no dependancy. 

lqr() function in MATLAB is used to determine K value which internally tries to minimize this cost function J as well as makes sure it satisfies Ricatti equation. 

## Requirements

For this project to work there are few requirements to be met:

1. Control System Toolbox
2. Aerospace Toolbox
3. FlightGear 2020 or above 

## Details on files 

1. **state_space.m** - This file contains all the variables needed as per the technical paper assuming constant velocity vector as well as aerodynamic forces for simplicity. It then calculates the A, B, C and D matrix for state space representation. Here we output the states itself and so C is identity matrix and D=0. Finally using ss() function, state space model is made. **The technical paper assumes pitch angle, pitch rate and angle of attack as state space of the system but in this project instead of angle of attack, Z-direction drift rate is been taken and so all the state space matrices slightly differ from the paper point of view. To check these matrices yourselves you need to build up equations for drift rate in terms of inputs and states.**

2. **LQR_cost.m** - This is a function file which is called in the state_space.m file. This function inputs state_space made in the state_spcae file and takes a boolean variable 'draw', whether to plot the root locus of the closed system or plotting the eigenvalues for individual states, and finally inputs Velocity V. This file also defines Q and R matrices for cost function where we have 3 states and 1 input as TVC angle. Using lqr() function we get the optimal K gain for each of the 3 states. Thes gains would be used in simulating in simulink.

3. **LQR_control.slx** - This is the simulink block diagram of the model with full state feedback with gains obtained from the workspace calculated by our LQR_cost() function. Here the output from the state space model is then used to calculate height climbed, and drift distance due to wind disturbances incorporated in the A matrix itself. These are then passed through Flat Earth to LLA block which converts traditional cartesian coordinates to Longitude, latitude and altitude given the reference. This conversion is been done in the simulink to Flightgear subsystem where we input instantaneous coordinates and reference altitude as -1000. This format of coordinates are required by fightgear to simulate the environment and the rocket model. In the FlightGear Preconfigured 6DoF Animation block, it inputs the LLA coordinates and the updated pitch angle as we are not dealing with roll and yaw angles. In this block, destination IP is your own hardware on which you are using and the port is most commonly 5502 used by flightgear, also sampling time is given for 30 Hz frequency.

![2021-07-09 (10)](https://user-images.githubusercontent.com/69386934/125071272-b341f700-e0d6-11eb-824c-b89dfcf96a33.png)

Here to see how weights affect the performance of the system, consider having Q as:
        
        Q_matrix_drift = [1 0 1/V; 0 0 0; 1/V 0 1/V^2];
then, the pitch angle and drift plots are like this:

<img src="https://user-images.githubusercontent.com/69386934/125072234-f6509a00-e0d7-11eb-98cc-8b66a78916b6.png" width="500" height="400">         <img src="https://user-images.githubusercontent.com/69386934/125072242-f9e42100-e0d7-11eb-82ae-2a46ba19ae96.png" width="450" height="400">

Clearly, we can see that at the end of 180s (3 mins), rocket drifts almost 3.5 kms and pitch angle stabilizes pretty quickly which is good. Apart from these plots there are altitude and latitude&logitude plots : 

<img src="https://user-images.githubusercontent.com/69386934/125073827-2ac55580-e0da-11eb-9ed1-f647b814aecd.png" width="400" height="400">        <img src="https://user-images.githubusercontent.com/69386934/125073908-44669d00-e0da-11eb-9296-9d65494ccb8d.png" width="400" height="400">

Viewing the above plots its clear that longitude and latitude are nearly constant because though drift is happenin gits not too large to change even 1 degree. Also rocket picks up altitude in a quadratic manner as there is constant Thrust force on it been applied its just that initially thrust direction was been tuned by the controller which quickly stabilized it.

Now if we try a different Q matrix like:

        Q_matrix_drift = [1 0 1/V^2; 0 0 0; 1/V^2 0 1/V^4];
Here we can see that V being a constant variable we used it to decrease the weight values even more mainly for drift part as we can see its in the 4th power of V inverse compared to 2nd power of V inverse in pitch angle. And since we know that lower the weight values, high the states importance in control aspect, thus drift should minimize for this case. So again the pitch angle and drift plot for this case are:

<img src="https://user-images.githubusercontent.com/69386934/125074844-7298ac80-e0db-11eb-8343-25c9580f9fbb.png" width="500" height="400">         <img src="https://user-images.githubusercontent.com/69386934/125074870-804e3200-e0db-11eb-8766-1f73f363cc17.png" width="450" height="400">

We got the results as expected ! Though the theta stability got little disturbed but still it stabilizes pretty good. Note, that for both the cases Q_matrix_drift was always symmetric, this is because Q has to be symmetric as both X and X transpose deals with it.

4. **runfg.bat** - This is a windows batch file which will command flightgear to directly open a custom environment with custom model given in this file, for this refer to the references given which is a very good explanation! Also after the flightgear is opened when we start the simulink, flightgear responds to it on the 5502 port for me and works pretty good.

## References 

  Youtube reference fro LQR on launch vehicle - https://www.youtube.com/watch?v=b0vGbgdrIlA
  
  Youtube reference for flightgear and simulink linking - https://www.youtube.com/watch?v=jB-80cvV1Ao&t=0s
  
  Technical paper - https://ntrs.nasa.gov/citations/20090001165
