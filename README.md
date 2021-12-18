# geneticAlgorithmWorkShifts
This is a modified version of codes by R. Haupt from the book Practical Genetic Algorithms.
The original codes are also uploaded as a rar file (ga book cd.rar). I have changed the codes proviced there for solving a simple problem to adapt my problem which is arranging four people in shifts of a whole month. I have changed the cost function to consider the limitations of different people for days in week and vacations. I also have changed the coding and decoding functions of that codes and decodes the variables to chromosomes and vice versa.

GAbinary.m ---->main function to run in Matlab

gadecodeShift.m ------> decoder function that decodes binary chromosomes to variable domain (here shift schedule of people along a month)

shiftCostFunc.m ------> cost function that calculate the cost of every shift pattern that the genetic algorithm randomly (through mutation and ....) generates.
