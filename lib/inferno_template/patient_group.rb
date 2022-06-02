require "uri"
require "json"
require "net/http"
require 'webmock/rspec'
require 'logger'

module InfernoTemplate
 
  class PatientGroup < Inferno::TestGroup
    title 'Patient  Tests'
    description 'Verify that the server makes Patient resources available'
    id :patient_group

    test do
      title 'Server returns requested Patient resource from the Patient read interaction'
      description %(
        Verify that Patient resources can be read from the server.
      )

      input :patient_id
      # Named requests can be used by other tests
      makes_request :patient

      run do
        fhir_read(:patient, patient_id, name: :patient)

        assert_response_status(200)
        assert_resource_type(:patient) 
        assert resource.id == patient_id,
               "Requested resource with id #{patient_id}, received resource with id #{resource.id}"
      end
    end

    
    test do
      title 'Patient match is valid'
      description %(
        Verify that the Patient  $match resource returned from the server is a valid FHIR resource.
      )
      #input :search_json
      #input :patient_id
      output :response_json
      # Named requests can be used by other tests
      makes_request :match
      
      
       # create a "default" client for a group
      # fhir_client do
       #  url :url
      #end
      logger= Logger.new(STDOUT)
      # create a named client for a group
      fhir_client  do
        url :url
      end
      #fhir_client :with_custom_header do
      #  url :url
      #  headers { 'Content-Type': 'application/fhir+json' }
     #end
      run do
        #body = JSON.dump(search_json)
          body = {
            "resourceType": "Parameters",
            "id": "example",
            "parameter": [
              {
                "name": "resource",
                "resource": {
                  "resourceType": "Patient",
                  "id": "1244780",
                  "meta": {
                    "versionId": "1",
                    "lastUpdated": "2020-06-22T07:37:44.914+00:00",
                    "source": "#Hep7oN0aHNPLwGdq",
                    "tag": [
                      {
                        "system": "http://terminology.hl7.org/CodeSystem/v3-ObservationValue",
                        "code": "SUBSETTED",
                        "display": "Resource encoded in summary mode"
                      }
                    ]
                  },
                  "identifier": [
                    {
                      "type": {
                        "coding": [
                          {
                            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                            "code": "DL",
                            "display": "Drivers License"
                          }
                        ],
                        "text": "Drivers License"
                      },
                      "value": "Q147604567"
                    },
                    {
                      "type": {
                        "coding": [
                          {
                            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                            "code": "NIIP",
                            "display": "National Insurance Payor Identifier"
                          }
                        ],
                        "text": "National Insurance Payor Identifier"
                      },
                      "value": "9800010077"
                    }
                  ],
                  "name": [
                    {
                      "family": "Queentin",
                      "given": [
                        "Vladimir"
                      ]
                    }
                  ],
                  "maritalStatus": {
                    "coding": [
                      {
                        "system": "http://terminology.hl7.org/CodeSystem/v3-MaritalStatus",
                        "code": "M"
                      }
                    ]
                  },
                  "telecom": [
                    {
                      "system": "phone",
                      "value": "344-845-5689",
                      "use": "mobile"
                    }
                  ],
                  "address": [
                    {
                      "type": "physical",
                      "line": [
                        "321 South Maple Street"
                      ],
                      "city": "Scranton",
                      "state": "PA",
                      "postalCode": "18503",
                      "use": "home"
                    }
                  ],
                  "contact": [
                    {
                      "relationship": [
                        {
                          "coding": [
                            {
                              "system": "http://hl7.org/fhir/v2/0131",
                              "code": "C",
                              "display": "Emergency Contact"
                            }
                          ]
                        }
                      ],
                      "telecom": [
                        {
                          "system": "phone",
                          "value": "726-555-1094",
                          "use": "home"
                        }
                      ]
                    }
                  ],
                  "gender": "male",
                  "birthDate": "1956-12-01"
                }
              },
              {
                "name": "count",
                "valueInteger": "3"
              },
              {
                "name": "onlyCertainMatches",
                "valueBoolean": "false"
              }
            ]
          }
          { 'Content-Type': 'application/fhir+json' }
         
          
          fhir_operation("Patient/$match", body: body, client: :default, name: nil, headers: { 'Content-Type': 'application/fhir+json' })

          
          #response_json=response[:body]
          output response_json: response[:body]
          assert_response_status(200)
          assert_resource_type(:bundle)
             
      end
    end
    test do
      input :response_json
      title 'Patient match - determines whether or not the $match function returns every valid record'
      description %(Match output SHOULD contain every record of every candidate identity, subject to volume limits
      )
      run do
        puts response_json
        response=JSON.parse(response_json)
        puts("Entry Count=" +   response[:total])
      end
    end
  end
end