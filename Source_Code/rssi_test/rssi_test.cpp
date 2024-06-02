#include <iostream>
#include <cmath>
#include <vector>

// Constants
const double targetDistance = 2.0; // Target distance in meters
const double tolerance = 0.01; // Tolerance for distance in meters
const double rssiValue = -63.0;

// Function to calculate distance using the RSSI formula
double calculateDistance(double measuredPower, double rssi, double n) {
    return std::pow(10, ((measuredPower - rssi) / (10 * n)));
}

int main() {
    std::vector<std::pair<double, double>> results; // Vector to store tested values and their distances

    // Loop to test different values of Tx Power and N
    for (double measuredPower = -100; measuredPower <= 0; measuredPower += 1) {
        for (double n = 2; n <= 4; n += 0.1) {
            double calculatedDistance = calculateDistance(measuredPower, rssiValue, n); // Assuming constant RSSI value
            // std::cout << txPower << "\t" << n << "\t" << calculatedDistance << "\n";

            // If calculated distance is within tolerance of target distance, save the values
            if (std::abs(calculatedDistance - targetDistance) <= tolerance) {
                std::cout << "mPower: " << measuredPower << "\tN: " << n << "\tdX: " << calculatedDistance << "\n";
                results.push_back(std::make_pair(measuredPower, n));
            }
        }
    }

    std::cout << calculateDistance(-63, -60, 3.3) << " m\n";
    std::cout << calculateDistance(-63, -62, 3.3) << " m\n";
    std::cout << calculateDistance(-63, -70, 3.3) << " m\n";
    std::cout << calculateDistance(-63, -72, 3.3) << " m\n";
    std::cout << calculateDistance(-63, -89, 3.3) << " m\n";
    std::cout << calculateDistance(-63, -90, 3.3) << " m\n";
    std::cout << calculateDistance(-63, -94, 3.3) << " m\n";
    std::cout << calculateDistance(-63, -97, 3.3) << " m\n";

    return 0;
}


/*




    // Displaying the results
    // std::cout << "Tx Power\tN" << std::endl;
    // std::cout << "------------------" << std::endl;
    // for (auto result : results) {
    //     std::cout << result.first << "\t\t" << result.second << std::endl;
    // }
*/
