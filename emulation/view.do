view wave
dataset open ./veloce.wave/wave1.stw wave1
wave add -d wave1 hdltop.cpu_contr.*
wave add -d wave1 {hdltop.cpu_model_inst.state[3:0]}
wave add -d wave1 hdltop.error
#wave add -d wave1 hdltop.*
#echo "wave1.stw loaded and signals added. Open the Wave window to observe outputs."
