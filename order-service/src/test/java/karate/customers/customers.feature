Feature: Customer API Tests

  Background:
    * url baseUrl
    * def customersPath = '/api/customers'

  @smoke
  Scenario: Create a new customer successfully
    Given path customersPath
    And request { firstName: 'John', lastName: 'Doe', email: 'john.doe@karate-test.com' }
    When method post
    Then status 201
    And match response.id == '#number'
    And match response.firstName == 'John'
    And match response.lastName == 'Doe'
    And match response.email == 'john.doe@karate-test.com'
    And match response.createdAt == '#string'
    * def customerId = response.id

  Scenario: Create customer with invalid email returns 400
    Given path customersPath
    And request { firstName: 'John', lastName: 'Doe', email: 'invalid-email' }
    When method post
    Then status 400

  Scenario: Create customer with blank firstName returns 400
    Given path customersPath
    And request { firstName: '', lastName: 'Doe', email: 'test@example.com' }
    When method post
    Then status 400

  Scenario: Create customer with duplicate email returns 409
    # First, create a customer
    Given path customersPath
    And request { firstName: 'Jane', lastName: 'Smith', email: 'duplicate@karate-test.com' }
    When method post
    Then status 201

    # Try to create another with same email
    Given path customersPath
    And request { firstName: 'Another', lastName: 'User', email: 'duplicate@karate-test.com' }
    When method post
    Then status 409
    And match response.message contains 'already exists'

  @smoke
  Scenario: Get customer by ID
    # First, create a customer
    Given path customersPath
    And request { firstName: 'GetTest', lastName: 'Customer', email: 'gettest@karate-test.com' }
    When method post
    Then status 201
    * def customerId = response.id

    # Then retrieve by ID
    Given path customersPath, customerId
    When method get
    Then status 200
    And match response.id == customerId
    And match response.firstName == 'GetTest'
    And match response.lastName == 'Customer'
    And match response.email == 'gettest@karate-test.com'

  Scenario: Get non-existent customer returns 404
    Given path customersPath, 99999
    When method get
    Then status 404
    And match response.status == 404
    And match response.message contains 'Customer'

  @smoke
  Scenario: Get all customers with pagination
    # Create some customers first
    Given path customersPath
    And request { firstName: 'Page1', lastName: 'User1', email: 'page1user1@karate-test.com' }
    When method post
    Then status 201

    Given path customersPath
    And request { firstName: 'Page1', lastName: 'User2', email: 'page1user2@karate-test.com' }
    When method post
    Then status 201

    # Get paginated results
    Given path customersPath
    And param page = 0
    And param size = 10
    When method get
    Then status 200
    And match response.data == '#array'
    And match response.page == 0
    And match response.size == 10
    And match response.totalElements == '#number'
    And match response.totalPages == '#number'

  Scenario: Update customer successfully
    # First, create a customer
    Given path customersPath
    And request { firstName: 'Original', lastName: 'Name', email: 'update@karate-test.com' }
    When method post
    Then status 201
    * def customerId = response.id

    # Update the customer
    Given path customersPath, customerId
    And request { firstName: 'Updated', lastName: 'Customer', email: 'update@karate-test.com' }
    When method put
    Then status 200
    And match response.firstName == 'Updated'
    And match response.lastName == 'Customer'

  Scenario: Update customer to use existing email returns 409
    # Create first customer
    Given path customersPath
    And request { firstName: 'First', lastName: 'Customer', email: 'first@karate-test.com' }
    When method post
    Then status 201
    * def firstCustomerId = response.id

    # Create second customer
    Given path customersPath
    And request { firstName: 'Second', lastName: 'Customer', email: 'second@karate-test.com' }
    When method post
    Then status 201

    # Try to update first customer to use second's email
    Given path customersPath, firstCustomerId
    And request { firstName: 'First', lastName: 'Customer', email: 'second@karate-test.com' }
    When method put
    Then status 409

  Scenario: Update non-existent customer returns 404
    Given path customersPath, 99999
    And request { firstName: 'Test', lastName: 'User', email: 'notfound@example.com' }
    When method put
    Then status 404

  Scenario: Delete customer successfully
    # First, create a customer
    Given path customersPath
    And request { firstName: 'ToDelete', lastName: 'Customer', email: 'delete@karate-test.com' }
    When method post
    Then status 201
    * def customerId = response.id

    # Delete the customer
    Given path customersPath, customerId
    When method delete
    Then status 204

    # Verify customer is deleted
    Given path customersPath, customerId
    When method get
    Then status 404

  Scenario: Delete non-existent customer returns 404
    Given path customersPath, 99999
    When method delete
    Then status 404
