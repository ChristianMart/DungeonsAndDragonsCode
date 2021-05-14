clc
clear
close all

%% Variables
% Proficiency Bonus for the Straight Roll
    Prof = 3;
% Attack Modifier for the Straight Roll
    AtkMod = 3;
% Attack Damage Bonus for the Straight Attack
    AtkBonus = 3;
% Number of damage dice rolled for the Straight Attack
    nDice = 1;
% Number of sides of the damage dice for the Straight Attack
    dSides = 8;
% The lowest AC the Straight Roll can hit (nat 1)
    ACmin = 1 + Prof + AtkMod;
% The highest AC the Straight Roll can hit (nat 20)
    ACmax = 20 + Prof + AtkMod;

% Proficiency Bonus for the 2 Disadvantage Rolls
    disProf = 3;
% Attack Bonus for the 2 Disadvantage Rolls
    disAtkMod = 3;
% Attack Damage Bonus for the Disadvantage Attacks
    disAtkBonus = 3;
% Number of damage dice rolled for the Disadvantage Attacks
    disnDice = 1;
% Number of sides of the damage dice for the Disadvantage Attacks
    disdSides = 8;
% The lowest AC the 2 Disadvantage Rolls can hit (nat 1)
    disACmin = 1 + disProf + disAtkMod;
% The highest AC the 2 Disadvantage Rolls can hit (nat 20)
    disACmax = 20 + disProf + disAtkMod;

% Number of Sample Averages
    N = 5000;
% Number of rolls per average
    L = 1000;

%% Calculating Disadvantage Hit Probability
% Scenario: You need to *hit* the target this turn, and can either make 1
% attack at a normal roll or 2 attacks at disadvantage. Which are you
% better off going for?

advHit = avgAdvHitProb(N, L, Prof, AtkMod);
straightHit = avgStrHitProb(N, L, Prof, AtkMod);
disadvHit = avgDisHitProb(N, L, disProf, disAtkMod);

figure(1)
plot([ACmin:ACmax], straightHit, 'r', [disACmin:disACmax], disadvHit, 'b', [ACmin:ACmax], advHit, 'k');
title('Probability of Hitting the Target');
xlabel('Target Armor Class (AC)');
ylabel('Percent Chance to Hit (%)');
legend('1 Straight Roll', '2 Rolls at Disadvantage', '1 Roll at Advantage', 'Location', 'southwest');
grid on
grid minor

%% Calculating Disadvantage Damage Probabilty
% Scenario: You need to do as much damage as possible the target this turn,
% and can either make 1 attack at a normal roll or 2 attacks at 
% disadvantage. Which are you better off going for?

advDmg = avgAdvDmgProb(N, L, Prof, AtkMod, AtkBonus, nDice, dSides)
straightDmg = avgStrDmgProb(N, L, Prof, AtkMod, AtkBonus, nDice, dSides)
disadvDmg = avgDisDmgProb(N, L, disProf, disAtkMod, disAtkBonus, disnDice, disdSides)

figure(2)
plot([ACmin:ACmax], straightDmg, 'r', [disACmin:disACmax], disadvDmg, 'b', [ACmin:ACmax], advDmg, 'k');
title('Average Damage of an Attack Based on Target Armor Class');
xlabel('Target Armor Class (AC)');
ylabel('Average Damage Done per Attack');
legend('1 Straight Roll', '2 Rolls at Disadvantage', '1 Roll at Advantage');
grid on
grid minor

%% General Functions
function X = average(a)
    X = sum(a)/length(a);
end
function X = rollDisadvantage(roll1, roll2)
    for R = 1:length(roll1)
        if roll1(R) <= roll2(R)
            X(R) = roll1(R);
        else
            X(R) = roll2(R);
        end
    end
end
function X = rollAdvantage(roll1, roll2)
    for R = 1:length(roll1)
        if roll1(R) >= roll2(R)
            X(R) = roll1(R);
        else
            X(R) = roll2(R);
        end
    end
end

%% Hit Probability Functions
function X = probStrHit(roll, ac, prof, mod)
    vec = zeros(1, length(roll));
    for R = 1:length(roll)
        if (((roll(R) + mod + prof) >= ac) && (roll(R) ~= 1))
            vec(R) = 1;
        end
    end
    X = average(vec);
end
function X = generateStrRollProb(number, lngth, ac, prof, mod)
    X = zeros(1, number);
    rng('shuffle');
    for R = 1:number
        rolls = randi(20, 1, lngth);
        X(R) = probStrHit(rolls, ac, prof, mod);
    end
end
function X = avgStrHitProb(number, lngth, prof, mod)
    X = zeros(1, 20);
    for R = 0:19
        strRollVal = generateStrRollProb(number, lngth, 1 + prof + mod + R, prof, mod);
        X(R+1) = 100 * average(strRollVal);
    end
end

function X = probDisHit(roll1, roll2, ac, prof, mod)
    vec = zeros(1, length(roll1));
    for R = 1:length(roll1)
        if((((roll1(R) + mod + prof) >= ac) && (roll1(R) ~= 1)) || (((roll2(R) + mod + prof) >= ac) && (roll2(R) ~= 1)))
            vec(R) = 1;
        end
    end
    X = sum(vec)/length(vec);
end
function X = generateDisRollProb(number, lngth, ac, prof, mod)
    X = zeros(1, number);
    rng('shuffle');
    for R = 1:number
        roll1 = randi(20, 1, lngth);
        roll2 = randi(20, 1, lngth);
        roll3 = randi(20, 1, lngth);
        roll4 = randi(20, 1, lngth);
        disRoll12 = rollDisadvantage(roll1, roll2);
        disRoll34 = rollDisadvantage(roll3, roll4);
        X(R) = probDisHit(disRoll12, disRoll34, ac, prof, mod);
    end
end
function X = avgDisHitProb(number, lngth, prof, mod)
    X = zeros(1, 20);
    for R = 0:19
        disRollVal = generateDisRollProb(number, lngth, 1 + prof + mod + R, prof, mod);
        X(R+1) = 100 * average(disRollVal);
    end
end

function X = probAdvHit(roll1, roll2, ac, prof, mod)
    vec = zeros(1, length(roll1));
    for R = 1:length(roll1)
        if((((roll1(R) + mod + prof) >= ac) && (roll1(R) ~= 1)) || (((roll2(R) + mod + prof) >= ac) && (roll2(R) ~= 1)))
            vec(R) = 1;
        end
    end
    X = sum(vec)/length(vec);
end
function X = generateAdvRollProb(number, lngth, ac, prof, mod)
    X = zeros(1, number);
    rng('shuffle');
    for R = 1:number
        roll1 = randi(20, 1, lngth);
        roll2 = randi(20, 1, lngth);
        roll3 = randi(20, 1, lngth);
        roll4 = randi(20, 1, lngth);
        disRoll12 = rollAdvantage(roll1, roll2);
        disRoll34 = rollAdvantage(roll3, roll4);
        X(R) = probAdvHit(disRoll12, disRoll34, ac, prof, mod);
    end
end
function X = avgAdvHitProb(number, lngth, prof, mod)
    X = zeros(1, 20);
    for R = 0:19
        AdvRollVal = generateAdvRollProb(number, lngth, 1 + prof + mod + R, prof, mod);
        X(R+1) = 100 * average(AdvRollVal);
    end
end

%% Damage Probability Functions
function X = strAvgDmg(roll, ac, prof, mod, bonus, dice, sides)
    vec = zeros(1, length(roll));
    crit = zeros(1, length(roll));
    for R = 1:length(roll)
        if (((roll(R) + mod + prof) >= ac) && (roll(R) ~= 1))
            vec(R) = vec(R) + 1;
            crit(R) = crit(R) + 1;
        end
        if (roll(R) == 20)
            crit(R) = crit(R) + 1;
        end
    end
    X = average(crit) * dice * (average([1:sides])) + average(vec) * bonus;
end
function X = generateStrDmgProb(number, lngth, ac, prof, mod, bonus, dice, sides)
    X = zeros(1, number);
    rng('shuffle');
    for R = 1:number
        rolls = randi(20, 1, lngth);
        X(R) = strAvgDmg(rolls, ac, prof, mod, bonus, dice, sides);
    end
end
function X = avgStrDmgProb(number, lngth, prof, mod, bonus, dice, sides)
    X = zeros(1, 20);
    for R = 0:19
        strDmgVal = generateStrDmgProb(number, lngth, 1 + prof + mod + R, prof, mod, bonus, dice, sides);
        X(R+1) = average(strDmgVal);
    end
end

function X = disadvAvgDmg(roll1, roll2, ac, prof, mod, bonus, dice, sides)
    vec = zeros(1, length(roll1));
    crit = zeros(1, length(roll1));
    for R = 1:length(roll1)
        if ((roll1(R) ~= 1) && (((roll1(R) + prof + mod) >= ac)))
            vec(R) = vec(R) + 1;
            crit(R) = crit(R) + 1;
        end
        if (roll1(R) == 20)
            crit(R) = crit(R) + 1;
        end
        if ((roll2(R) ~= 1) && (((roll2(R) + prof + mod) >= ac)))
            vec(R) = vec(R) + 1;
            crit(R) = crit(R) + 1;
        end
        if (roll2(R) == 20)
            crit(R) = crit(R) + 1;
        end
    end
    X = average(crit) * dice * (average([1:sides])) + average(vec) * bonus;
end
function X = generateDisDmgProb(number, lngth, ac, prof, mod, bonus, dice, sides)
    X = zeros(1, number);
    rng('shuffle');
    for R = 1:number
        roll1 = randi(20, 1, lngth);
        roll2 = randi(20, 1, lngth);
        roll3 = randi(20, 1, lngth);
        roll4 = randi(20, 1, lngth);
        disRoll12 = rollDisadvantage(roll1, roll2);
        disRoll34 = rollDisadvantage(roll3, roll4);
        X(R) = disadvAvgDmg(disRoll12, disRoll34, ac, prof, mod, bonus, dice, sides);
    end
end
function X = avgDisDmgProb(number, lngth, prof, mod, bonus, dice, sides)
    X = zeros(1, 20);
    for R = 0:19
        disRollVal = generateDisDmgProb(number, lngth, 1 + prof + mod + R, prof, mod, bonus, dice, sides);
        X(R+1) = average(disRollVal);
    end
end

function X = advAvgDmg(roll, ac, prof, mod, bonus, dice, sides)
    vec = zeros(1, length(roll));
    crit = zeros(1, length(roll));
    for R = 1:length(roll)
        if ((roll(R) ~= 1) && (((roll(R) + prof + mod) >= ac)))
            vec(R) = vec(R) + 1;
            crit(R) = crit(R) + 1;
        end
        if (roll(R) == 20)
            crit(R) = crit(R) + 1;
        end
    end
    X = average(crit) * dice * (average([1:sides])) + average(vec) * bonus;
end
function X = generateAdvDmgProb(number, lngth, ac, prof, mod, bonus, dice, sides)
    X = zeros(1, number);
    rng('shuffle');
    for R = 1:number
        roll1 = randi(20, 1, lngth);
        roll2 = randi(20, 1, lngth);
        advRoll12 = rollAdvantage(roll1, roll2);
        X(R) = advAvgDmg(advRoll12, ac, prof, mod, bonus, dice, sides);
    end
end
function X = avgAdvDmgProb(number, lngth, prof, mod, bonus, dice, sides)
    X = zeros(1, 20);
    for R = 0:19
        advRollVal = generateAdvDmgProb(number, lngth, 1 + prof + mod + R, prof, mod, bonus, dice, sides);
        X(R+1) = average(advRollVal);
    end
end
