(* Mathematica Package *)


BeginPackage["FLUKAmatica`"]
(* Exported symbols added here with SymbolName::usage *) 


ImportSingleBDX::usage = "ImportSingleBDX[data,i] returns a list of data \
{{energyLow, energyHi, magnitude, relError},...} from a Flair-produced \
file *_tab.lis which has been imported as string in 'data'. Physical meaning: magnitude * \
(1\[PlusMinus]relError) is the he magnitude per energy in \
[energyLow, energyHi]. Note the magnitude is usually per area per primary."

ImportDoubleBDX::usage = "DEPRECATED: ImportDoubleBDX[tabLisString] returns a list of data \
{angleMesh,energyMesh,data,...} from a Flair-produced \
file *_tab.lis which has been imported as string. Physical meaning: magnitude * \
(1\[PlusMinus]relError) is the magnitude per energy per solid angle in \
[energyLow, energyHi] and in [angleLow,angleHi]. Note the magnitude is usually per area per primary. The higher limit is \
the next's lower limit. The last interval always contains no counts, \
it is used to keep all this information."



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

GetDoubleHistogramData[
  det_] := {GetDetectorAngularMesh[det], 
   GetDetectorIntegratedTable[det][[All, {1, 2}]]}~Join~
  Transpose[
   GetDetectorDoubleDiffTables[det][[All, 1 ;; -2, {3, 4}]], {2, 3, 1}]
GetDoubleHistogramData::usage = 
  "Reads a detector as a double histogram, a list of: angle mesh, \
energy mesh, data (indexed by angle, energy), data's relative error \
(in %)";

FIXBUG[dTables_] := 
 Block[{new, l}, new = dTables; l = Length[dTables[[-2]]]; 
  new[[-1]] = new[[-1, 1 ;; l]]; new]

FIXEDGetDoubleHistogramData[
  det_] := {GetDetectorAngularMesh[det], 
   GetDetectorIntegratedTable[det][[All, {1, 2}]]}~Join~
  Transpose[
   FIXBUG[GetDetectorDoubleDiffTables[det]][[All, 
    1 ;; -2, {3, 4}]], {2, 3, 1}]
    

ImportDoubleBDX[file_]:=FIXEDGetDoubleHistogramData/@TabLisBreakDetectors[file]





     
     
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

