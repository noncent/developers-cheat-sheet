// This is the function to trigger CloudFront Cache Invalidation
// when a new file get's update/upload/delete on S3
// Runtime requirement is NodeJS 20

import { CloudFrontClient, CreateInvalidationCommand } from "@aws-sdk/client-cloudfront";

// Environment variables
const CLOUDFRONT_DISTRIBUTION_ID = process.env.CLOUDFRONT_DISTRIBUTION_ID;
const S3_BUCKET = process.env.S3_BUCKET;

// AWS SDK CloudFront client
const cloudFrontClient = new CloudFrontClient();

// Constants for S3 event names
const S3_EVENT_CREATED = 'ObjectCreated';
const S3_EVENT_REMOVED = 'ObjectRemoved';

// Lambda handler function
export const handler = async (event) => {
  try {
    // Iterate through S3 events
    for (const record of event.Records) {
      const eventName = record.eventName;
      console.log('logEventName: ', eventName); // ObjectCreated:Put or ObjectRemoved:Delete
      const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));

      // Trigger cache invalidation for ObjectCreated or ObjectRemoved events
      if (eventName.startsWith(S3_EVENT_CREATED) || eventName.startsWith(S3_EVENT_REMOVED)) {
        await invalidateCloudFrontCache(cloudFrontClient, CLOUDFRONT_DISTRIBUTION_ID, `/${key}`);
      }
    }

    // Lambda execution successful response
    return {
      statusCode: 200,
      body: JSON.stringify('Cache invalidation triggered successfully'),
    };
  } catch (error) {
    // Handle errors and provide appropriate response
    console.error('Error:', error.message || error);
    return {
      statusCode: 500,
      body: JSON.stringify('Error occurred during cache invalidation'),
    };
  }
};

// Function to invalidate CloudFront cache
async function invalidateCloudFrontCache(cloudFrontClient, distributionId, path) {
  // CloudFront invalidation parameters
  const params = {
    DistributionId: distributionId,
    InvalidationBatch: {
      CallerReference: Date.now().toString(),
      Paths: {
        Quantity: 1,
        Items: [path],
      },
    },
  };

  // Create CloudFront invalidation command
  const command = new CreateInvalidationCommand(params);

  try {
    // Send the invalidation command to CloudFront
    const response = await cloudFrontClient.send(command);
    return response;
    // console.log('Successful!!! Cache removed for: ', path);
  } catch (error) {
    // Handle CloudFront errors and log the details
    console.error('CloudFront Error:', error.message || error);
    throw error; // Re-throw the error for further handling or logging if needed
  }
}
