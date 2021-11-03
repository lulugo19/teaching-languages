# Evaluation of *Teaching Languages* using the example of computer games
This repository is created as part of my [bachelor thesis](./BA_Bewertung_und_Vergleich_von_Teaching_Languages)

Examination and evaluation of programming languages that are beginner friendly and easy to learn and teach (*Teaching Languages*).

For each *Teaching Language* there is an implementation of three different games (*Tic-Tac-Toe*, *Flappy Bird* and *Tamagochi*).
Besides the games there is also the [*Fibonacci Sequence*](https://en.wikipedia.org/wiki/Fibonacci_number) implemented recursivly for each language and *Bouncing Ball* where a ball bounces off the border of the game field.

# Choice of *Teaching Languages*
1. [Pyret](https://www.pyret.org/)
2. [Quorum](https://quorumlanguage.com/)
3. [Scratch](https://scratch.mit.edu/)
4. [ToonTalk](http://www.toontalk.com/)
5. [GameChangineer](https://gc.ece.vt.edu/)

# Choice of Games
1. [Tic-Tac-Toe](https://en.wikipedia.org/wiki/Tic-tac-toe)
2. [Flappy Bird](https://en.wikipedia.org/wiki/Flappy_Bird)
3. [Simplified Tamagochi](https://en.wikipedia.org/wiki/Tamagotchi)

## Simplified Tamagochi Rules
The pet has two status values ```love``` and ```energy``` that can be affected by the click of three different symbols: `heart`, `broccoli` and `cake`. The game is lost, when the ```love``` has sunk on the value 0.

- The two status values have a value range from 0 to 100.
- The default change of the `energy` and `love` is a decrease of 1 per second.
- When `heart` is clicked, the energy decreases by 15 and the love increases by 10.
- When `broccoli` is clicked, the `love` decreases by 10 and the `energy` increases by 15.
- When `cake` is clicked, there is 30% chance that the pet becomes sick. The sickness remains for 15 seconds. When the pet is sick, its energy decreases by 3 per second.
- While the pet is sick, the `heart` and `cake` can't be clicked.
- When `energy` is smaller equals 10, then the pet falls asleep for 10 seconds. While it is asleep, the `energy` regenerates by 2 per second and if the pet is sick, the sickness is removed.
- When `love` sunks on the value 0, the pet dies. Then the total lifetime of the pet ist displayed and the game can be restarted by the press on a button.

# Playing the games
For playing the games the code must be copied, built and run in the respective teaching language environment.

*Scratch* and *Pyret* allow to publish the game online. Here are the links:

| Language | Bouncing Ball | Tic-Tac-Toe | Flappy Bird | Tamagochi |
| -------- | ------------- | ----------- | ----------- | --------- |
| **Scratch** | [Link](https://scratch.mit.edu/projects/528813158/) | [Link](https://scratch.mit.edu/projects/519645989/) | [Link](https://scratch.mit.edu/projects/520032916/) | [Link](https://scratch.mit.edu/projects/520609677/) |
| **Pyret** | [Link](https://code.pyret.org/editor#share=1WipznC33V05qX1OHLnZyn6NDwFpl06TZ&v=04918ef) | [Link](https://code.pyret.org/editor#share=1BeSqwazyy9H91pUq3UmseWfq06paNx3L&v=04918ef)| [Link](https://code.pyret.org/editor#share=1SfbRBL_GRpyReX8iDa2iyjINMEj6nDyT&v=04918ef) | [Link](https://code.pyret.org/editor#share=1SfbRBL_GRpyReX8iDa2iyjINMEj6nDyT&v=04918ef) |
