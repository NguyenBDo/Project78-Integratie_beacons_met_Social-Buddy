#include <iostream>
#include <cmath>
#include <vector>

// using namespace std;

// Constants
const double targetDistance = 2.0; // Target distance in meters
const double tolerance = 0.01; // Tolerance for distance in meters
const double rssiValue = -63.0;

// Function to calculate distance using the RSSI formula
double calculateDistance(double txPower, double rssi, double n) {
    return std::pow(10, ((txPower - rssi) / (10 * n)));
}

int main() {
    std::vector<std::pair<double, double>> results; // Vector to store tested values and their distances

    // Loop to test different values of Tx Power and N
    for (double txPower = -100; txPower <= 0; txPower += 1) {
        for (double n = 2; n <= 4; n += 0.1) {
            double calculatedDistance = calculateDistance(txPower, rssiValue, n); // Assuming constant RSSI value of -50
            // std::cout << txPower << "\t" << n << "\t" << calculatedDistance << "\n";

            // If calculated distance is within tolerance of target distance, save the values
            if (std::abs(calculatedDistance - targetDistance) <= tolerance) {
                std::cout << "Tx: " << txPower << "\tN: " << n << "\tdX: " << calculatedDistance << "\n";
                results.push_back(std::make_pair(txPower, n));
            }
        }
    }

    std::cout << calculateDistance(-53, -89, 3.3) << "\n";
    std::cout << calculateDistance(-53, -90, 3.3) << "\n";
    std::cout << calculateDistance(-53, -94, 3.3) << "\n";
    std::cout << calculateDistance(-53, -97, 3.3) << "\n";

    // Displaying the results
    // std::cout << "Tx Power\tN" << std::endl;
    // std::cout << "------------------" << std::endl;
    // for (auto result : results) {
    //     std::cout << result.first << "\t\t" << result.second << std::endl;
    // }

    return 0;
}

