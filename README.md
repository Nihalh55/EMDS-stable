# Encrypted Message Delivery System (EMDS)

In a world where security and privacy have become a top priority for citizens
and nations alike, encryption has become an exceedingly necessary element to
communication.

This mini-project aims to implement a digital circuit that can:
1. Allow two users to communicate with one another using text messages.
    * ASCII characters
    * Keyboard input in Logisim
    * Displaying Messages using a TTY in Logisim.
    * FIN and FOUT in Verilog.

2. Ask each user for a password to enable communication.
    * Use LED lights to indicate whether communication is enabled.
    * 4 Digit PINs for both user.

3. Encrypt the message to prevent interference.
    * Using some kind of homomorphic encryption

4. Transmit the message using a transmission circuit of choice.
    * Using wired transmission in Logisim and Verilog.


    Possible Real World Implementation:
    * A HT12E/D to Encode and Decode the data before and after transmission.
    * RF434 Transmitter for the transmission.
