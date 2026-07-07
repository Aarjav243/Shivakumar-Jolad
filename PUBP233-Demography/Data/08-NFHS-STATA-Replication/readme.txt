These are the STATA dofiles for the paper:
"Social disadvantage, economic inequality, and life expectancy in nine Indian states," 
accepted for publication in PNAS.
Pre-print version available here: https://osf.io/preprints/socarxiv/vkacx/

Please cite the PNAS paper accordingly, if you cite any of the findings in your work.

If you have questions about the dofiles, you may contact the authors: 
Sangita Vyas, Payal Hathi, and Aashish Gupta.

Info about the dofiles contained here:
The main analyses conducted here use data from the Annual Health Survey, conducted by the Indian government. The data used to be available on a government website. However this website is no longer functional. Please see the archive of the website here: https://web.archive.org/web/20200923145449/https://nrhm-mis.nic.in/hmisreports/AHSReports.aspx.

The raw data are now now available here: https://zenodo.org/record/6062984#.YgmCoUntyUk

Prior to running these dofiles, you must download the comb and mort datasets for all states in csv format. 

We also use data from the NFHS-4 and SRS. These data are publicly available from:
- NFHS: https://www.dhsprogram.com/methodology/survey/survey-display-355.cfm
- SRS: https://censusindia.gov.in/vital_statistics/Appendix_SRS_Based_Life_Table.html

The NFHS life tables were constructed by Gupta and Sudharshan (2020). Pre-print paper available here: https://osf.io/preprints/socarxiv/hu8t9/. They kindly provided a dataset with the life tables that we use in our analysis. They have also kindly permitted the sharing of that dataset with users in our replication files provided here. 

dofiles starting with 0 compile all the csv datasets
- run both

dofiles starting with 1 clean and prepare the dataset for analysis
- run 1a, 1c, 1e
- 1b and 1d are dofiles that are called into the other dofiles and do not need to be run separately

dofiles starting with 2 run lifetables
- run 2a
- 2b is a dofiles that is called into 2a and does not need to be run separately

dofiles starting with 3 perform the bootstrap (standard error construction) and the decomposition analysis
- run all

dofiles for constructing each figure in the paper are saved as fig*



 