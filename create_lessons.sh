#!/bin/zsh

# Create the Lessons directory
mkdir -p Lessons

# Define an array of lesson names
lessons=(
    "01_introduction_to_faunadb.md"
    "02_setting_up_faunadb.md"
    "03_integrating_faunadb_with_nextjs.md"
    "04_building_graphql_api_with_faunadb.md"
    "05_crud_operations_with_faunadb.md"
    "06_authentication_and_authorization.md"
    "07_real_time_features_with_faunadb.md"
    "08_performance_optimization.md"
    "09_testing_faunadb_integrations.md"
    "10_deploying_application.md"
    "11_case_studies.md"
    "12_capstone_project.md"
)

# Create blank markdown files for each lesson
for lesson in "${lessons[@]}"; do
    touch "Lessons/$lesson"
done

echo "Lessons directory and markdown files created successfully!"
