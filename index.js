// index.js

exports.handler = async function(event, context) {
  console.log("Hello, World!");
  return {
    statusCode: 200,
    body: "Hello, World!"
  };
}

