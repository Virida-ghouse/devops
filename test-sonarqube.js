// Test file for SonarQube analysis
function calculateSum(a, b) {
    // This function has a potential issue for SonarQube to detect
    if (a == null || b == null) {
        return 0;
    }
    return a + b;
}

// Unused variable - SonarQube should detect this
var unusedVariable = "This should be flagged";

// Duplicate code - SonarQube should detect this
function duplicateFunction1() {
    console.log("Hello World");
    console.log("This is duplicate code");
}

function duplicateFunction2() {
    console.log("Hello World");
    console.log("This is duplicate code");
}

module.exports = { calculateSum };
