const Web3 = require('web3');

// Initialize Web3
const web3 = new Web3('<YOUR_WEB3_PROVIDER_URL>'); // Example: 'https://mainnet.infura.io/v3/YOUR_PROJECT_ID'

// Contract setup
const contractABI = "<YOUR_CONTRACT_ABI>";
const contractAddress = '<YOUR_CONTRACT_ADDRESS>';
const teachEvalContract = new web3.eth.Contract(contractABI, contractAddress);

// Account setup (Replace with your account and ensure it's funded for gas costs)
const accountAddress = '<YOUR_ACCOUNT_ADDRESS>';
const privateKey = '<YOUR_PRIVATE_KEY>'; // Consider using environment variables for security

// Utility function to create a signed transaction
async function sendTransaction(transaction) {
    const options = {
        to: contractAddress,
        data: transaction.encodeABI(),
        gas: await transaction.estimateGas({from: accountAddress}),
        gasPrice: await web3.eth.getGasPrice(), // Or set manually
    };
    const signed = await web3.eth.accounts.signTransaction(options, privateKey);
    return await web3.eth.sendSignedTransaction(signed.rawTransaction);
}

// CRUD Operations
// Add more functions as per your contract's capabilities

// Choose a Course
async function chooseCourse(courseId) {
    const transaction = teachEvalContract.methods.chooseCourse(courseId);
    return await sendTransaction(transaction);
}

// Enroll in a Course
async function enrollCourse(courseId) {
    const transaction = teachEvalContract.methods.enrollCourse(courseId);
    return await sendTransaction(transaction);
}

// Submit a Review
async function submitReview(courseId, ratings) {
    const transaction = teachEvalContract.methods.submitReview(courseId, ratings);
    return await sendTransaction(transaction);
}

// View Review
async function viewReview(courseId) {
    const reviews = await teachEvalContract.methods.viewReview(courseId).call();
    console.log(reviews);
    return reviews;
}

// Example Usage (Uncomment to test)
/*
(async () => {
    try {
        await chooseCourse(1);
        await enrollCourse(1);
        await submitReview(1, [5, 5, 5, 5, 5, 5, 5, 5, 5, 5]);
        await viewReview(1);
    } catch (error) {
        console.error(error);
    }
})();
*/

// Exporting the functions for external use
module.exports = {
    chooseCourse,
    enrollCourse,
    submitReview,
    viewReview,
};
