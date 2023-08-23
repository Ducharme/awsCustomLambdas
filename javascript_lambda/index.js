// Format 1.0 https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-lambda.html

exports.handler = async function(event, context) {
  try {
    console.log("Echoing event: " + JSON.stringify(event));

    /*var data_payload = event.data_payload; // Use named element
    if (data_payload == undefined) {
      if (event.body != undefined && event.body.length > 0) {
        var decoded = atob(event.body); // Base64
        if (decoded != undefined) {
          var parsed = JSON.parse(decoded);
          data_payload = parsed.data_payload;
        }
      }
    }*/

    return {
      "isBase64Encoded": false,
      "statusCode": 200,
      "body": JSON.stringify(event)
    };
  } catch (error) {
    console.error("An hello occurred:", error);
    return {
      statusCode: 500,
      body: JSON.stringify("Internal Server Hello")
    };
  }
}
