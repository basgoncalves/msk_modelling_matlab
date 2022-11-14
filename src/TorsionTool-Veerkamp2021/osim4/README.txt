1. Open the main script (MAIN_TorsionTool).
2. Give the subject-specific femoral anteversion (AV) and neck-shaft (NS) angles,
	as well as the tibial torsion (TT) angles, as input for the right and left leg.
	Lines which require these inputs are indicated by a % at the end of the line.
3. The final model with personalised torsions is saved in the DEFORMED_MODEL
	folder, and is called FINAL_PERSONALISEDTORSIONS.osim.
	The adjusted markerset can also be found in this folder.

note1: The angle definitions for AV and TT are as follows:
	- AV: positive: femoral anteversion; negative: femoral retroversion.
	- TT: positive: external rotation; negative: internal rotation.
note2: Adjust the MarkerSet.xml in the main folder to your marker set,
	when using markers for the greater trochanter (when adjusting
	femur) and/or when using markers on the feet (when adjusting tibia).
note3: If you only wish to adjust the femoral geometry (and not the tibial
	torsion), set the input to the tibial torsion to 0 degrees (=default
	tibial torsion in generic femur).