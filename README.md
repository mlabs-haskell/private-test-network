** <b>This is a work in proccess - the directions below are not official or a finished product. They are just for people that want to play around with the project as it's worked on:</b>


1) get the docker image

`docker run stackchain/private-network:0.1`

2) get into the image:

`docker run --rm --interactive --tty stackchain/private-network:0.1`

3) open a tmux shell:

`tmux`

4) configure the network:

`./start.sh`

5) go to the run directory:

`cd example/run`

6) start the 3 nodes:

`./all.sh`

7) get out of the tmux shell:

Ctr-B and then press D 

8) query the tip a few times and make sure everything is running and blocks are being made:

`cardano-cli query tip --testnet-magic 42`

* If block production staopped or never started, go back into the tmux shell:
		
		`tmux attach` and press Ctr-C twice 

* Then go back to the main folder:

		`cd $NODE_HOME

* Erase the example folder:

		`rm -r -f example/`

* Start over at step 4 (in the TMUX shell).
		
9) <b>Wait untill at least epoch 1</b> and run 1-toShelley:

`./1-toShelley.sh` 

10) Continue to check the tip and wait for era Shelley and then run 2-toAllegra with the current epoch as a variable (ex `./2-toAllegra.sh 2` ): 

`./2-toAllegra.sh (current epoch)` 

* If you get an error durring any of the updates use the next epoch as the variables (ex if `./2-toAllegra.sh 2` gives you an error, try `./2-toAllegra.sh 3`) 
		
11) restart the nodes by going back in to the tmux shell:

`tmux attach`

12) press Ctr-C twice to stop the nodes.

13) restart all the nodes:

`./all.sh`

14) get out of the tmux shell with Ctr-B and press D.

15)  query the tip and wait untill it changes to Allegra and the run './3-toMary.sh` with the current epoch:

`./3-toMary.sh (current epoch)`

16) repeate the process to restart the nodes (steps 11 - 14) 

17) query the tip and wait untill it changes to Mary and then run `./4-toAlonzo.sh` with the current epoch:

`./4-toAlonzo.sh (current epoch)`

18) repeate the process to restart the nodes (steps 11 - 14) 

19) Query the tip until you are in Alonzo. 

You now have a working private alonzo chain.


