#include <iostream>
#include <fstream>
#include <string>
#include <algorithm>  // Potrebno za std::remove

int main() {
    std::ifstream inputFile("index1Dbin.txt");
    std::ofstream outputFile("index1D.txt");
    std::string line;

    if (!inputFile.is_open()) {
        std::cerr << "Nije moguće otvoriti ulazni fajl." << std::endl;
        return 1;
    }

    while (getline(inputFile, line)) {
        // Uklanjanje "0b"
        size_t index = line.find("0b");
        while (index != std::string::npos) {
            line.erase(index, 2);
            index = line.find("0b", index);
        }

        // Uklanjanje tačaka
        line.erase(remove(line.begin(), line.end(), '.'), line.end());

        outputFile << line << std::endl;
    }

    inputFile.close();
    outputFile.close();

    std::cout << "Čišćenje završeno! Izmenjeni sadržaj je sačuvan u 'output.txt'." << std::endl;

    return 0;
}

