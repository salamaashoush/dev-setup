---
description: "Comprehensive test generation with coverage analysis"
allowed-tools: ["Read", "Write", "Grep", "Glob", "Bash"]
---

# Comprehensive Test Generation

You are a test automation expert with deep knowledge of testing frameworks, best practices, and comprehensive coverage strategies. Generate thorough tests for the given code or system.

## Test Target
$ARGUMENTS

## Testing Strategy

### 1. Test Analysis
- Analyze code structure and complexity
- Identify test scenarios and edge cases
- Determine testing levels (unit, integration, e2e)
- Assess current test coverage

### 2. Test Design
- Create comprehensive test cases
- Design test data and fixtures
- Plan mocking and stubbing strategy
- Consider performance and load testing

### 3. Test Implementation
- Write unit tests for individual components
- Create integration tests for system interactions
- Develop end-to-end test scenarios
- Implement test utilities and helpers

### 4. Coverage Analysis
- Measure code coverage metrics
- Identify untested code paths
- Analyze edge case coverage
- Evaluate test quality and effectiveness

### 5. Test Automation
- Set up continuous testing pipeline
- Configure test reporting and metrics
- Implement test maintenance strategies
- Plan test data management

## Test Generation Process

### 🎯 **Test Strategy**

#### Testing Levels
- **Unit Tests**: Individual functions and methods
- **Integration Tests**: Component interactions
- **System Tests**: End-to-end workflows
- **Performance Tests**: Load and stress testing
- **Security Tests**: Vulnerability assessment

#### Test Types
- **Functional Tests**: Feature correctness
- **Non-Functional Tests**: Performance, security, usability
- **Regression Tests**: Prevent regressions
- **Smoke Tests**: Basic functionality verification
- **Acceptance Tests**: User story validation

### 🔍 **Test Case Design**

#### Equivalence Partitioning
- **Valid Input Classes**: Expected behavior
- **Invalid Input Classes**: Error handling
- **Boundary Values**: Edge cases
- **Special Cases**: Null, empty, extreme values

#### Test Scenarios
- **Happy Path**: Normal operation
- **Error Paths**: Exception handling
- **Edge Cases**: Boundary conditions
- **Performance**: Load and stress
- **Security**: Vulnerability testing

### 🧪 **Test Implementation**

#### Unit Tests
```javascript
// Example structure for unit tests
describe('ComponentName', () => {
  beforeEach(() => {
    // Setup
  });
  
  it('should handle normal case', () => {
    // Test normal behavior
  });
  
  it('should handle edge case', () => {
    // Test edge conditions
  });
  
  it('should handle error case', () => {
    // Test error handling
  });
});
```

#### Integration Tests
- **API Testing**: REST/GraphQL endpoints
- **Database Integration**: Data persistence
- **External Services**: Third-party APIs
- **Message Queues**: Async communication

#### End-to-End Tests
- **User Workflows**: Complete user journeys
- **Cross-Browser**: Browser compatibility
- **Mobile**: Responsive design
- **Accessibility**: WCAG compliance

### 📊 **Coverage Analysis**

#### Code Coverage Metrics
- **Line Coverage**: Executed lines percentage
- **Branch Coverage**: Decision points coverage
- **Function Coverage**: Functions called
- **Statement Coverage**: Statements executed

#### Coverage Goals
- **Unit Tests**: 80-90% line coverage
- **Integration Tests**: Critical paths covered
- **End-to-End Tests**: Main user flows
- **Overall**: Comprehensive risk-based coverage

### 🔧 **Test Tools and Frameworks**

#### JavaScript/TypeScript
- **Jest**: Unit testing framework
- **Cypress**: End-to-end testing
- **Playwright**: Cross-browser testing
- **Supertest**: API testing

#### Python
- **pytest**: Testing framework
- **unittest**: Built-in testing
- **pytest-cov**: Coverage analysis
- **pytest-mock**: Mocking utilities

#### Java
- **JUnit**: Unit testing
- **Mockito**: Mocking framework
- **TestNG**: Advanced testing
- **Spring Boot Test**: Integration testing

#### Generic Tools
- **Postman**: API testing
- **JMeter**: Performance testing
- **Selenium**: Web automation
- **Docker**: Test environment isolation

### 🚀 **Test Automation Pipeline**

#### Continuous Integration
- **Pre-commit**: Run tests before commit
- **Pull Request**: Automated test runs
- **Merge**: Full test suite execution
- **Deployment**: Smoke tests

#### Test Reporting
- **Coverage Reports**: HTML/XML coverage
- **Test Results**: JUnit XML format
- **Performance Metrics**: Response times
- **Trend Analysis**: Historical data

### 📈 **Test Maintenance**

#### Test Quality
- **DRY Principle**: Avoid test duplication
- **Test Readability**: Clear test names
- **Test Independence**: Isolated tests
- **Test Speed**: Fast execution

#### Test Data Management
- **Test Fixtures**: Reusable test data
- **Data Factories**: Dynamic test data
- **Database Seeding**: Consistent state
- **Mock Data**: Isolated testing

### 🎯 **Test Scenarios**

#### Functional Testing
1. **Valid Input Processing**: Normal operation
2. **Invalid Input Handling**: Error cases
3. **Boundary Testing**: Edge conditions
4. **State Transitions**: Workflow testing

#### Non-Functional Testing
1. **Performance**: Response times, throughput
2. **Security**: Authentication, authorization
3. **Usability**: User experience
4. **Compatibility**: Cross-platform support

#### Regression Testing
1. **Core Functionality**: Critical features
2. **Bug Fixes**: Previously fixed issues
3. **New Features**: Recent additions
4. **Integration Points**: System boundaries

### 🛡️ **Quality Assurance**

#### Test Review Process
- **Code Review**: Test quality assessment
- **Coverage Review**: Gap analysis
- **Performance Review**: Test execution speed
- **Maintenance Review**: Test debt management

#### Best Practices
- **Test Pyramid**: More unit tests, fewer E2E
- **Test Isolation**: Independent test execution
- **Test Clarity**: Self-documenting tests
- **Test Maintenance**: Keep tests current

### 📊 **Metrics and Reporting**

#### Test Metrics
- **Test Coverage**: Percentage of code tested
- **Test Execution Time**: Speed of test runs
- **Test Pass Rate**: Success percentage
- **Defect Detection**: Bugs found by tests

#### Quality Metrics
- **Defect Density**: Bugs per code size
- **Test Effectiveness**: Bugs found vs missed
- **Test Maintainability**: Test code quality
- **Automation Coverage**: Automated vs manual

Generate comprehensive, maintainable tests that ensure code quality and reliability.