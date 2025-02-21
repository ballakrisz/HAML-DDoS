# HAML-DDoS

## Using docker with vscode (after Docker, nvidia container toolkit and everything else has been downloaded)

For the development phase of my solution a docker-based visual studio code approach is taken. To separate the development environment from my own personal environment, a visual studio code server is attached to the running container so I can write my code in the vscode IDE inside the container (where all the necessary packages are installed):  
1. Download the 'Dev Containers' and 'Docker' vscode extensions.  
2. On the 'Docker' panel (left sidebar) right click on the running container and choose 'attach visual studio code'