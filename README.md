# Train evacuation model using NetLogo
## Purpose
The proposed model simulates people evacuating from a train in case of fire and explores the results of different evacuation strategies. This model is composed of the driver driving the train, passengers travelling in the train and the staff members where all of them represent the agents. The model can generate several results within a few seconds.
In case of fire in real world, the staff members tend to be calm and try to stop the fire in the train and then provide support to passengers. Passengers either escaped by themselves, follow staff instructions quietly using the closest safe path or might get panic and delay their evacuation. 
This model helps to analyze the phenomenon of evacuation in case of a fire in the train. The behavior of passengers and staff in addition to fire intensity determine how this phenomenon evolves over time and space. 

## Sample Simulation 
![](complex-version/images/simulation-screenshot.gif)

## Sample Simulation Results
![](complex-version/images/simulation-results.jpg)

## Interface paramters
![](complex-version/images/paramters.jpg)


## Process overview and scheduling
The model stimulation can be divided into four main parts: passengers’ behavior  (escape from train), staff members behavior (stopping the fire, helping passengers or escape from train), driver behavior (escape from train) and fire behavior (spread or be stopped). All those behaviors are being affected by each other and have direct influence on the stimulation results. 

### Passengers behavior
The model contains a function to initialize the passengers in the train “initialize-passengers” which create N passengers: N is an input from a slider between 1 and 60. This function set default values for all passengers’ attributes (not safe, not dead, and full health=100, …etc.). Then they are all distributed over available seats in the train (one person per one seat). 
Based on panic-rate value which comes as an input from a slider, the function set corresponding probability of panic passengers in the train. Another similar input is the “probability-to-get-panic” which is a value indicate the probability for passengers to get panic when they are close to fire area. We have defined two main color to distinguish panic attribute: red for panic passenger, yellow for non-panic passenger.
The social network is implemented in the model. There are four possible types of relationships: “family, couple, friends and colleagues”. 
The percentage of passengers who are in relations depends on the relation probability value which comes as input from a slider “relation-probability”. Probability to be in relationships for every passenger is random number (1-100), and the relative passenger will be selected based on the distance (passengers who sit next to each other -in radius 30- may have relation between each other). 
Passengers who are in-relation have the same group-id which helps to identify the group and ease controlling their total behavior. Moreover, passengers who belong to the same group are connected between each other with “directed-link”. In the simulation, there is a possibility to show/hide those links and relations. 

### Normal passengers’ behavior 
At first, each passenger has his own target-exit which is set based on the distance to all exits (minimum distance = closest exit). This type of passengers does not have any relations with any other passengers, and by definition they are not panic.
They start moving with clear and specific path to escape from the train. First, they leave their seats and move the main path, then they walk slowly and steady to the hall which lead to their target-exit. Once they are in the halls they move up/down towards the doors, then they get out of the train to the “cyan” area and they are considered as “safe” passengers and colored “green”.
In case of being close to any fire or smoke spots, the health of passenger is decreased by 10, he might get panic based on “probability-to-get-panic” parameter and if so then they follow “panic” passengers’ behavior,  and he change his direction and target exit. If the health value is 0, then the passenger is dead. 

### Panic passengers’ behavior
Similar to normal passengers, they are initialized at first with same default values except for (panic= true and color = red). 
They start by moving randomly in the train (because they are stressed), and once they are close enough to one of target exits (in radius 30), they manage to get out of the train successfully. 
They also have possibility to change moving direction if necessary (reaching a wall or close to a fire), and again their health is affected by fire.

### In-relation passengers’ behavior
Passengers who are in-relation, they have different behavior. The model first sets the same target-exit to all passengers who are in the same group. Then the model check the panic people in those groups, if the number of panic passengers are greater than the number of normal passengers, then all passengers in the group will be “panic” and becomes “orange”, otherwise all passengers in the group will be “normal = not panic” and their colors are same  “yellow or red”. 
For example: one group with 2 passengers, one of them is “normal and yellow” and the other is “panic and red”. Then the panic one will be “normal and red” 
So, the group member’s behavior are either considered as normal-passengers with one target-exit where they follow the same behavior of normal passengers or considered as panic-passengers and they follow panic passengers’ behavior. 
Once one of the passengers in one group change his/her direction, the “target-exit” is changed for the whole group. This is the case where the first (head) passenger is closed to one fire or smoke spot. 
### Staff members’ behavior
The model contains a function to initialize the staff members in the train “initialize-staff” which create N staff members: N is an input from a slider between 0 and 8. This function set default values for all staff members’ attributes (not safe, not dead, and full health=300, …etc.). Then they are all distributed over available special staffs’ seats in the train (one staff per one staff seat) and are dressed in blue suits. 
There are different behaviors implemented for staff members: stop fire, calm down passengers, or help them to escape.
Firs of all, staff members try to stop the fire in the train. If the stimulation contains more than one fire location, then each staff member moves to his own closest fire spot and tries to stop the fire. When his target-fire is stopped, he moves to the next closest fire spot and so on until there are no more fire-spots in the train. If a staff member is closed to one fire spot, there is a probability that his health value will be decreased (by 2 points), when the value reaches 0 then he is dead. 
When the fire is stopped in all the train, the staff members start helping passengers (panic ones have more priority). Each one of staff members try to go to the closest panic passenger and provide help and support to calm him/her down. Once there are no panic passengers left in the train, they start helping normal passengers to escape from the train. 
At the end, when there are no passengers to help, staff members escape from the train and considered as “safe” and “green”.

