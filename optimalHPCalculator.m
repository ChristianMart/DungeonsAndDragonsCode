clc
clear
close all

%% Variables

% Base Variables
lowEnmBonusToHit = 15;
highEnmBonusToHit = 15;
enmBonusDmg = 7;
nDice = 8;
dSides = 6;

% Control, Marius at Level 7 (with Hag Curse)
conAC = 17;
conHP = 58;

% Scenario 1: Level 8 with Hag Curse without changes
s1AC = 17;
s1HP = 67;

% Scenario 2:  Level 8 without Hag Curse without changes
s2AC = 17;
s2HP = 74;

% Scenario 3:  Level 8 without Hag Curse with changes
s3AC = 15;
s3HP = 83;

%% Scenario: 
% This past level up, Marius' Constitution increased to 20 and
% his Dexterity decreased to 13. This means that his HP increased by 8
% while his AC decreased by 2. The question is, would it have been better
% for Marius to keep his previous stat line, or is this change a complete
% upgrade?

for X = lowEnmBonusToHit:highEnmBonusToHit
    contProb(X - (lowEnmBonusToHit - 1)) = probHit(conAC, X);
    s1Prob(X - (lowEnmBonusToHit - 1)) = probHit (s1AC, X);
    s2Prob(X - (lowEnmBonusToHit - 1)) = probHit (s2AC, X);
    s3Prob(X - (lowEnmBonusToHit - 1)) = probHit (s3AC, X);
end

contAvgDmg = [];
for X = nDice + enmBonusDmg:nDice * dSides + enmBonusDmg
    contAvgDmg = [contAvgDmg; avgDmg(contProb, enmBonusDmg, X)];
end
contAvgTurns = average(turnsToLive(conHP, contAvgDmg))

s1AvgDmg = [];
for X = nDice + enmBonusDmg:nDice * dSides + enmBonusDmg
    s1AvgDmg = [s1AvgDmg; avgDmg(s1Prob, enmBonusDmg, X)];
end
s1AvgTurns = average(turnsToLive(s1HP, s1AvgDmg))

s2AvgDmg = [];
for X = nDice + enmBonusDmg:nDice * dSides + enmBonusDmg
    s2AvgDmg = [s2AvgDmg; avgDmg(s2Prob, enmBonusDmg, X)];
end
s2AvgTurns = average(turnsToLive(s2HP, s2AvgDmg))

s3AvgDmg = [];
for X = nDice + enmBonusDmg:nDice * dSides + enmBonusDmg
    s3AvgDmg = [s3AvgDmg; avgDmg(s3Prob, enmBonusDmg, X)];
end
s3AvgTurns = average(turnsToLive(s3HP, s3AvgDmg))


%% Basic Functions

function X = average(a)
    [A, B] = size(a);
    X = sum(a, 'all')/(A * B);
end
function X = probHit(ac, bonus)
    vec = zeros(1, 20);
    for R = 1:20
        if (((R + bonus) >= ac) && (R ~= 1))
            vec(R) = 1;
        end
        if (R == 20)
            vec(R) = 1;
        end
    end
    X = average(vec);
end
function X = avgDmg(prob, bonusdmg, dmg)
    for N = 1:length(prob)
        X(N) = prob(N) * (dmg + bonusdmg) + 0.05 * (dmg);
    end
end
function N = turnsToLive(hp, avgdmg)
    [A, B] = size(avgdmg);
    for X = 1:A
        for Y = 1:B
            N(X, Y) = ceil(hp / avgdmg(X, Y));
        end
    end
end

