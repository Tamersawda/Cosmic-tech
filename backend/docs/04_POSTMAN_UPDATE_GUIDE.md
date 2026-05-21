# 04_POSTMAN_UPDATE_GUIDE.md

## Postman Collection Update Guide

### 1. File Location
**Collection File Path:** ackend/postman/Therapy-Booking-MVP-API.postman_collection.json

---

## 2. POSTMAN COLLECTION UPDATE INSTRUCTIONS

### Overview
This guide provides comprehensive instructions for maintaining and updating the Therapy Booking MVP API Postman collection. It includes pre-request scripts, test templates, and validation examples to ensure consistency across all API endpoints.

---

## 3. Pre-request Script to Normalize Field Names

### JavaScript Code
Add this script to the Pre-request Script tab for normalization:

\\\javascript
// Pre-request Script: Normalize Field Names
// Converts snake_case to camelCase and validates required fields

(function() {
    // Snake case to camel case converter
    function snakeToCamel(str) {
        return str.replace(/_([a-z])/g, (g) => g[1].toUpperCase());
    }

    // Normalize request body
    function normalizeBody(obj) {
        if (!obj || typeof obj !== 'object') return obj;
        
        const normalized = {};
        for (const key in obj) {
            const camelKey = snakeToCamel(key);
            normalized[camelKey] = obj[key];
        }
        return normalized;
    }

    // Get current request body
    const bodyData = pm.request.body.raw;
    
    if (bodyData) {
        try {
            const parsed = JSON.parse(bodyData);
            const normalized = normalizeBody(parsed);
            pm.request.body.raw = JSON.stringify(normalized, null, 2);
            
            console.log('✓ Field names normalized');
            console.log('Normalized body:', normalized);
        } catch (e) {
            console.error('Error normalizing fields:', e);
        }
    }

    // Set timestamp
    pm.environment.set('request_timestamp', new Date().toISOString());
})();
\\\

---

## 4. Test Script Template for Validation

### JavaScript Code
Add this template to the Tests tab for response validation:

\\\javascript
// Test Script: Response Validation Template

const response = pm.response.json();
const request = pm.request;

// Helper function: Check status code
function validateStatusCode(expectedCode) {
    pm.test(\Status code is \\, function() {
        pm.expect(pm.response.code).to.equal(expectedCode);
    });
}

// Helper function: Check response schema
function validateSchema(expectedFields) {
    pm.test('Response contains required fields', function() {
        expectedFields.forEach(field => {
            pm.expect(response).to.have.property(field);
        });
    });
}

// Helper function: Check field types
function validateFieldTypes(fieldTypes) {
    pm.test('Field types are correct', function() {
        for (const [field, type] of Object.entries(fieldTypes)) {
            pm.expect(response[field]).to.be.a(type);
        }
    });
}

// Helper function: Validate data integrity
function validateDataIntegrity(sentData) {
    pm.test('Sent data matches response', function() {
        for (const [key, value] of Object.entries(sentData)) {
            if (response[key] !== undefined) {
                pm.expect(response[key]).to.equal(value);
            }
        }
    });
}

// Helper function: Store variable for next request
function storeVariable(varName, valuePath) {
    const value = getValue(response, valuePath);
    if (value) {
        pm.environment.set(varName, value);
        pm.test(\Stored \ for next request\, function() {
            pm.expect(value).to.exist;
        });
    }
}

// Helper function: Get nested value
function getValue(obj, path) {
    return path.split('.').reduce((current, prop) => current?.[prop], obj);
}

// Run validations
validateStatusCode(200);
validateSchema(['id', 'createdAt', 'updatedAt']);
validateFieldTypes({ id: 'number', createdAt: 'string', updatedAt: 'string' });

console.log('✓ All validation tests completed');
\\\

---

## 5. Collection Variables Setup

### Required Variables

Create these variables in your Postman Collection > Variables tab:

| Variable Name | Initial Value | Current Value | Description |
|---|---|---|---|
| baseUrl | http://localhost:3000 | | Base URL for API endpoints |
| token | {{token}} | | JWT authentication token |
| doctorId | | | Doctor record ID (set after doctor creation) |
| qualificationId | | | Qualification record ID |
| experienceId | | | Experience record ID |
| availabilityId | | | Availability record ID |
| appointmentId | | | Appointment record ID |

### Setting Variables Programmatically

In your pre-request script, set variables like this:

\\\javascript
// Set variables
pm.collectionVariables.set("baseUrl", "http://localhost:3000");
pm.collectionVariables.set("token", "your-jwt-token");
pm.collectionVariables.set("doctorId", "1");

// Access variables
const baseUrl = pm.collectionVariables.get("baseUrl");
const token = pm.collectionVariables.get("token");
\\\

---

## 6. Request Body Templates for Each Endpoint

### Doctor Endpoints

#### Create Doctor
**Endpoint:** POST {{baseUrl}}/api/doctors
\\\json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "phone": "1234567890",
  "specialization": "Pediatrics",
  "licenseNumber": "LIC123456",
  "bio": "Experienced pediatrician",
  "profilePhoto": "https://example.com/photo.jpg"
}
\\\

#### Update Doctor
**Endpoint:** PUT {{baseUrl}}/api/doctors/{{doctorId}}
\\\json
{
  "firstName": "John",
  "lastName": "Doe",
  "specialization": "Pediatrics",
  "bio": "Updated bio",
  "phone": "1234567890"
}
\\\

### Qualification Endpoints

#### Add Qualification
**Endpoint:** POST {{baseUrl}}/api/doctors/{{doctorId}}/qualifications
\\\json
{
  "degree": "MD",
  "institution": "Harvard Medical School",
  "graduationYear": 2015,
  "description": "Medical degree from Harvard"
}
\\\

#### Update Qualification
**Endpoint:** PUT {{baseUrl}}/api/doctors/{{doctorId}}/qualifications/{{qualificationId}}
\\\json
{
  "degree": "MD",
  "institution": "Harvard Medical School",
  "graduationYear": 2015
}
\\\

### Experience Endpoints

#### Add Experience
**Endpoint:** POST {{baseUrl}}/api/doctors/{{doctorId}}/experiences
\\\json
{
  "jobTitle": "Senior Pediatrician",
  "institution": "City Hospital",
  "startYear": 2018,
  "endYear": null,
  "description": "Currently working as Senior Pediatrician"
}
\\\

#### Update Experience
**Endpoint:** PUT {{baseUrl}}/api/doctors/{{doctorId}}/experiences/{{experienceId}}
\\\json
{
  "jobTitle": "Senior Pediatrician",
  "institution": "City Hospital",
  "endYear": 2023
}
\\\

### Availability Endpoints

#### Create Availability
**Endpoint:** POST {{baseUrl}}/api/doctors/{{doctorId}}/availability
\\\json
{
  "dayOfWeek": "Monday",
  "startTime": "09:00",
  "endTime": "17:00",
  "consultationDuration": 30,
  "isActive": true
}
\\\

#### Update Availability
**Endpoint:** PUT {{baseUrl}}/api/doctors/{{doctorId}}/availability/{{availabilityId}}
\\\json
{
  "startTime": "09:00",
  "endTime": "18:00",
  "consultationDuration": 45,
  "isActive": true
}
\\\

### Appointment Endpoints

#### Create Appointment
**Endpoint:** POST {{baseUrl}}/api/appointments
\\\json
{
  "doctorId": "{{doctorId}}",
  "patientName": "Jane Smith",
  "patientEmail": "jane@example.com",
  "patientPhone": "0987654321",
  "appointmentDate": "2024-12-20",
  "appointmentTime": "14:00",
  "reasonForVisit": "Regular checkup",
  "notes": "First time patient"
}
\\\

#### Update Appointment
**Endpoint:** PUT {{baseUrl}}/api/appointments/{{appointmentId}}
\\\json
{
  "appointmentDate": "2024-12-21",
  "appointmentTime": "15:00",
  "status": "scheduled"
}
\\\

---

## 7. Response Validation Examples

### Successful Doctor Creation Response
**Status Code:** 201
\\\json
{
  "id": 1,
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "phone": "1234567890",
  "specialization": "Pediatrics",
  "licenseNumber": "LIC123456",
  "bio": "Experienced pediatrician",
  "profilePhoto": "https://example.com/photo.jpg",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
\\\

### Validation Test
\\\javascript
pm.test("Doctor created successfully", function() {
    pm.expect(pm.response.code).to.equal(201);
    pm.expect(pm.response.json()).to.have.property('id');
    pm.expect(pm.response.json()).to.have.property('firstName');
    pm.expect(pm.response.json().email).to.equal('john.doe@example.com');
});

// Store doctorId for subsequent requests
pm.collectionVariables.set('doctorId', pm.response.json().id);
\\\

### Successful Qualification Response
**Status Code:** 200
\\\json
{
  "id": 5,
  "doctorId": 1,
  "degree": "MD",
  "institution": "Harvard Medical School",
  "graduationYear": 2015,
  "description": "Medical degree from Harvard",
  "createdAt": "2024-01-15T11:00:00Z",
  "updatedAt": "2024-01-15T11:00:00Z"
}
\\\

### Successful Appointment Response
**Status Code:** 201
\\\json
{
  "id": 10,
  "doctorId": 1,
  "patientName": "Jane Smith",
  "patientEmail": "jane@example.com",
  "patientPhone": "0987654321",
  "appointmentDate": "2024-12-20",
  "appointmentTime": "14:00",
  "reasonForVisit": "Regular checkup",
  "notes": "First time patient",
  "status": "scheduled",
  "createdAt": "2024-01-15T10:45:00Z",
  "updatedAt": "2024-01-15T10:45:00Z"
}
\\\

---

## 8. How to Execute Updates

### Option A: Manual Updates in Postman

#### Step-by-Step Manual Process

1. **Open Postman Collection**
   - Launch Postman
   - Open the collection file: ackend/postman/Therapy-Booking-MVP-API.postman_collection.json

2. **Configure Variables**
   - Go to Collections > Your Collection > Variables
   - Set initial values for: baseUrl, token, doctorId, etc.
   - Save the collection

3. **Update Individual Requests**
   - Select each request in the collection
   - Update the body with the templates provided above
   - Add pre-request scripts as needed
   - Add test scripts to validate responses

4. **Test Each Endpoint**
   - Send the request
   - Verify the response matches expected schema
   - Check that variables are stored for dependent requests

5. **Execute Workflow**
   - Use Runner to execute collection in sequence
   - Monitor variable passing between requests
   - Review test results

### Option B: Scripts to Regenerate Collection

#### Using Collection JSON Generation Script

Create \scripts/generate-postman-collection.js\:

\\\javascript
const fs = require('fs');
const path = require('path');

// Collection template
const collection = {
  info: {
    name: 'Therapy-Booking-MVP-API',
    schema: 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json'
  },
  auth: {
    type: 'bearer',
    bearer: [{
      key: 'token',
      value: '{{token}}',
      type: 'string'
    }]
  },
  variable: [
    { key: 'baseUrl', value: 'http://localhost:3000' },
    { key: 'token', value: '' },
    { key: 'doctorId', value: '' },
    { key: 'qualificationId', value: '' },
    { key: 'experienceId', value: '' },
    { key: 'availabilityId', value: '' },
    { key: 'appointmentId', value: '' }
  ],
  item: [
    {
      name: 'Doctors',
      item: [
        {
          name: 'Create Doctor',
          request: {
            method: 'POST',
            header: [{ key: 'Content-Type', value: 'application/json' }],
            url: {
              raw: '{{baseUrl}}/api/doctors',
              host: ['{{baseUrl}}'],
              path: ['api', 'doctors']
            },
            body: {
              mode: 'raw',
              raw: JSON.stringify({
                firstName: 'John',
                lastName: 'Doe',
                email: 'john.doe@example.com',
                phone: '1234567890',
                specialization: 'Pediatrics',
                licenseNumber: 'LIC123456'
              }, null, 2)
            }
          },
          response: []
        }
      ]
    }
  ]
};

// Write collection to file
const outputPath = path.join(__dirname, '../backend/postman/Therapy-Booking-MVP-API.postman_collection.json');
fs.writeFileSync(outputPath, JSON.stringify(collection, null, 2));
console.log('✓ Postman collection generated successfully');
\\\

#### Run the Script

\\\ash
# From project root
node scripts/generate-postman-collection.js

# Verify output
cat backend/postman/Therapy-Booking-MVP-API.postman_collection.json
\\\

#### Automated Update Workflow

1. **Setup Automation**
   - Store collection configuration in JSON format
   - Create templates for each endpoint type
   - Setup version control for collection file

2. **Regenerate Collection**
   \\\ash
   npm run postman:generate
   \\\

3. **Validate Collection**
   \\\ash
   npm run postman:validate
   \\\

4. **Run Collection Tests**
   \\\ash
   npm run postman:test
   \\\

---

## Best Practices

1. **Variable Management**
   - Always use collection variables for dynamic values
   - Store IDs from responses for use in subsequent requests
   - Use environment variables for sensitive data

2. **Request Organization**
   - Group related endpoints in folders
   - Use consistent naming conventions
   - Document request purpose in descriptions

3. **Testing**
   - Add tests to every request that modifies data
   - Validate response schema and data types
   - Store required IDs for dependent requests

4. **Documentation**
   - Add descriptions to each request
   - Document required parameters
   - Include example responses

5. **Maintenance**
   - Keep collection in sync with API changes
   - Version the collection file with your code
   - Document any breaking changes

---

## Common Errors and Solutions

### Error: 404 Not Found
- Verify baseUrl is correct
- Check endpoint path spelling
- Ensure resource IDs are valid

### Error: 400 Bad Request
- Validate request body schema
- Check field names are camelCase
- Ensure required fields are present

### Error: 401 Unauthorized
- Verify token is set and valid
- Check Bearer token format
- Ensure token hasn't expired

### Error: 422 Validation Error
- Review field types match schema
- Check for required fields
- Validate data format (dates, emails, etc.)

---

## Additional Resources

- Postman Documentation: https://learning.postman.com/
- Collection Format: https://schema.getpostman.com/
- API Testing Best Practices: https://www.postman.com/api-testing/
