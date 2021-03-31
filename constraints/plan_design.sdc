VERSION 1.0
BEGIN SEED
	name=PD_CPU util=0.70 createFence=true minFenceToCoreSpace=20 minFenceToFenceSpace=20
	name=PD_DMEM util=0.70 createFence=true minFenceToCoreSpace=20 minFenceToFenceSpace=20
	name=PD_IMEM util=0.70 createFence=true minFenceToCoreSpace=20 minFenceToFenceSpace=20
END SEED

