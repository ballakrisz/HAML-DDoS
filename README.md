# Final Submission

## Build

#### First build the image
```bash
./build_docker.sh
```
#### Then run the container with
```bash
./run_docker.sh
```
(the shell scripts should be executable, as github preserves file permissions)

I recommend using vscode with the **Dev Containers** and **Docker** extensions. If you've installed them; On the **Docker** panel (left sidebar) right click on the running container and choose **attach visual studio code**.  

Make sure that for the notebooks you select the **3.10.14 python kernel**, as that is where all the depencies are installed. 

## Running the project
If you'd like to execute all of the provided code, please strictly follow this order:

#### (1) preprocess.ipynb
This is where the feature engineering happens, it takes around 20 minutes to execute all cells.

#### (2) visualization.ipynb
This is where all of the data analysis, class distributons and histograms are created

#### (3) For the different models there is no particular order, all of them are independent, just follow the instructions in the notebooks.