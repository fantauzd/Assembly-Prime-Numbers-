Program Requirements
The programmer’s name and program title must appear in the output.
The counting loop (1 to n) must be implemented using the LOOP instruction.
The main procedure must consist of only procedure calls (with any necessary framing). It should be a readable "list" of what the program will do.
Each procedure will implement a section of the program logic, i.e., each procedure will specify how the logic of its section is implemented. The program must be modularized into at least the following procedures and sub-procedures:
introduction
getUserData - Obtain user input
validate - Validate user input n is in specified bounds
showPrimes - display n prime numbers; utilize counting loop and the LOOP instruction to keep track of the number of primes displayed; candidate primes are generated within counting loop and are passed to isPrime for evaluation
isPrime - receive candidate value, return boolean (0 or 1) indicating whether candidate value is prime (1) or not prime (0)
farewell
The upper and lower bounds of user input must be defined as constants.
The USES directive is not allowed on this project.
If the user enters a number outside the range [1 ... 200] an error message must be displayed and the user must be prompted to re-enter the number of primes to be shown.
The program must be fully documented and laid out according to the CS271 Style Guide. This includes a complete header block for identification, description, etc., a comment outline to explain each block of code, and proper procedure headers/documentation.
