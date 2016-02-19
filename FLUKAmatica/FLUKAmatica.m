(* Mathematica Package *)


BeginPackage["FLUKAmatica`"]
(* Exported symbols added here with SymbolName::usage *) 


ImportSingleBDX::usage = "ImportSingleBDX[tabLisString] returns a list of detector data, each in the form \
{{energyLow, energyHi, magnitude, relError},...} from a Flair-produced \
file *_tab.lis which has been imported as a string.
Physical meaning: magnitude * (1\[PlusMinus]relError%) is the mean magnitude (e.g., fluence) per GeV in \
[energyLow, energyHi]. Note the magnitude is usually per [effective] area per primary."

ImportDoubleBDX::usage = "ImportDoubleBDX[tabLisString] returns a list of detector data, each in the form \
{angleMesh,energyMesh,data,error} from a Flair-produced file *_tab.lis which has been imported as string. 
angleMesh is a list with m elements, each of them a pair descring the solid angle interval in sr.
energyMesh is a list with n elements, each of them a pair descring the energy interval in GeV.
data is a m x n matrix. The element (i,j) describes the mean magnitude (e.g., fluence) per GeV per sr in the\
rectangle defined by angleMesh[[i]] x energyMesh[[j]].
error is a m x n matrix with the relative errors of data in %."



Begin["`Private`"]
(* Implementation of the package *)


	
TabLisBreakDetectors[tabLis_] := 
 DeleteCases[
  StringSplit[tabLis, 
   RegularExpression[
    "# Detector.*"]], _?(StringMatchQ[#, RegularExpression["\\s*"]] &)]
TabLisBreakDetectors::usage = 
  "Breaks a tab.lis string into a string per detector";
  
GetDetectorIntegratedTable[det_] := 
 DeleteCases[
  ImportString[
   DeleteCases[
     StringSplit[det, 
      RegularExpression[
       "#.*"]], _?(StringMatchQ[#, RegularExpression["\\s*"]] &)][[
    1]], "Table"], {}]
GetDetectorIntegratedTable::usage = 
  "Gets the angle-integrated table from a detector";
  
GetDetectorDoubleDiffTables[det_] := 
 Function[t, DeleteCases[ImportString[t, "Table"], {}]] /@ 
  DeleteCases[
    StringSplit[det, 
     RegularExpression[
      "#.*"]], _?(StringMatchQ[#, RegularExpression["\\s*"]] &)][[
   2 ;; -1]]
GetDetectorDoubleDiffTables::usage = 
  "Gets the list of angle-conditional tables from a detector";

GetDetectorAngularMesh[det_] := 
 Map[Internal`StringToDouble, (StringSplit[#, 
       RegularExpression["[^0123456789\\.]+"]] & /@ 
     StringCases[det, RegularExpression[ "# Block n:.*"]])[[All, 
   2 ;; 3]], {2}]
GetDetectorAngularMesh::usage = 
  "Gets the angular mesh from a detector";



FixDoubleTables[dTables_] := 
 Block[{new, l}, new = dTables; l = Length[dTables[[-2]]]; 
  new[[-1]] = new[[-1, 1 ;; l]]; new]
  FixDoubleTables::usage="Since _tab.lis files add some upper limits after the last element, they have to removed with this function.
  Check the bug or feature discuss at:
  http://www.fluka.org/web_archive/earchive/new-fluka-discuss/7671.html"

GetDoubleHistogramData[det_] := {GetDetectorAngularMesh[det], 
   GetDetectorIntegratedTable[det][[All, {1, 2}]]}~Join~
  Transpose[FixDoubleTables[GetDetectorDoubleDiffTables[det]][[All,1 ;; -2, {3, 4}]], {2, 3, 1}]
GetDoubleHistogramData::usage = 
  "Reads a detector as a double histogram, a list of: angle mesh, \
energy mesh, data (indexed by angle, energy), data's relative error \
(in %)";
    

ImportDoubleBDX[file_]:=GetDoubleHistogramData/@TabLisBreakDetectors[file]


     
     
ImportSingleBDX =     (DeleteCases[
     ImportString[
      DeleteCases[
        StringSplit[#, 
         RegularExpression[
          "#.*"]], _?(StringMatchQ[#, 
            RegularExpression["\\s*"]] &)][[1]], "Table"], {}] &) /@ 
  DeleteCases[
   StringSplit[#1, 
    RegularExpression[
     "# Detector.*"]], _?(StringMatchQ[#, 
       RegularExpression["\\s*"]] &)] &
     


(*DEPRECATED: all following functions must be adapted to the new double differential format*)
     
     IntegrateAngleForEnergy[t_, En_, nextEn_] := 
 Module[{value, error, t2},
  t2 = Select[t, #[[1]] == En &];
  (*Add as fifth element the upper bound to the solid angle*)
  t2 = Join[Drop[t2, -1], Drop[t2, 1][[All, {2}]], 2];
  value = Total[Map[#[[3]]*(#[[5]] - #[[2]]) &, t2]];
  error = Sqrt[Total[Map[((#[[3]]/100*#[[4]]*(#[[5]] - #[[2]]))^2) &, t2]]];
  {En, nextEn, value, If[value==0,0.,error/value*100]}]
  
  IntegrateAngle[t_] := Module[{enList},
  enList = DeleteDuplicates[Map[#[[1]] &, t]];
  Table[IntegrateAngleForEnergy[t, enList[[j]], enList[[j + 1]]], {j, 
    1, Length[enList] - 1}]
  ]
  IntegrateAngle::usage =
 "IntegrateAngle[t] integrates a double differential table \
(t={{energyLow, angleLow, Fluence, relError},...}) to produce single \
differential fluxes in energy {{energyLow, energyHi, Fluence, \
relError},...}. The relative error composes each error assuming they \
are gaussian, taking into account the exact shape of each interval. \
It should be very similar to FLUKA's postprocessing tools' results, \
which can also be imported using ImportIntegratedTabLis."
  
  IntegrateEnergyForAngle[t_, Angle_, nextAngle_] := 
 Module[{value, error, t2},
  t2 = Select[t, #[[2]] == Angle &];
  (*Add as fifth element the upper bound to the energy*)
  t2 = Join[Drop[t2, -1], Drop[t2, 1][[All, {1}]], 2];
  value = Total[Map[#[[3]]*(#[[5]] - #[[1]]) &, t2]];
  error = 
   Sqrt[Total[Map[((#[[3]]/100*#[[4]]*(#[[5]] - #[[1]]))^2) &, t2]]];
  {Angle, nextAngle, value, If[value==0,0.,error/value*100]}]
  
  IntegrateEnergy[t_] := Module[{AngleList},
  AngleList = DeleteDuplicates[Map[#[[2]] &, t]];
  Table[IntegrateEnergyForAngle[t, AngleList[[j]], 
    AngleList[[j + 1]]], {j, 1, Length[AngleList] - 2}]
  ]
IntegrateEnergy::usage =
 "IntegrateEnergy[t] integrates a double differential table \
(t={{energyLow, angleLow, Fluence, relError},...}) to produce single \
differential fluxes in angles {{angleLow, angleHi, Fluence, \
relError},...}. The relative error composes each error assuming they \
are gaussian, taking into account the exact shape of each interval."

End[]

EndPackage[]

