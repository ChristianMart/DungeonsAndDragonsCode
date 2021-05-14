clc
clear
close all
%%
nDice = input('How many dice are you rolling? ');
dSide = input('How many sides are on those dice? ');
dmgBonus = input('What is your bonus to damage? ');
spellDC = input('What is your spell save DC? ');
STbonus = input('What is the enemy`s bonus to the spell`s saving throw? ');

OutputDamage = avgDmgAOE(nDice, dSide, dmgBonus)
AverageDamage = spellSave(OutputDamage, spellDC, STbonus)


%%
function X = average(a)
    [A, B] = size(a);
    X = sum(a, 'all')/(A * B);
end
function X = avgDmgAOE(n, d, bonus)
    A = average([1:d]);
    X = (n * A) + bonus;
end
function X = spellSave(dmg, dc, st)
    s=zeros(1, 20);
    for n = 1:20
        if (n+st) >= dc
            s(n) = 0.5;
        else
            s(n) = 1;
        end
    end
    s = dmg * s;
    X = average(s);
end