cd ..
file mkdir coverage
exec xcrg -report_format html -dir uvm_project/surf_col.sim/sim_1/behav/xsim -report_dir coverage -merge_code_coverage
