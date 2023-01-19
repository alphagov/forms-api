# Pages structure
This document describes the structure of the pages objects which are passed between the admin, api and runner.

"Sent from admin" describes how questions are created through the admin in a POST request, for example:
```
POST /api/v1/forms/1/pages HTTP/1.1
Content-Type: application/json
Accept-Encoding: gzip, deflate
Accept: */*
User-Agent: Ruby
Connection: close
Host: localhost:9292
Content-Length: 124

{"question_text":"Number question","hint_text":"Hint text","answer_type":"number","is_optional":null,"answer_settings":null}
```


"Returned from API:" describes the structure of response form the API in a GET request, for example:

```
GET /api/v1/forms/1/pages/1 HTTP/1.1
Accept: application/json
Accept-Encoding: gzip, deflate
User-Agent: Ruby
Connection: close
Host: localhost:9292
```

The following types of question exist:

### Number
Sent from admin:
```json
{
  "question_text": "Number question",
  "hint_text": "Hint text",
  "answer_type": "number",
  "is_optional": null,
  "answer_settings": null
}
```

Returned from API
```json
{
  "id": 1,
  "question_text": "Number question",
  "question_short_name": null,
  "hint_text": "Hint text",
  "answer_type": "number",
  "is_optional": null,
  "answer_settings": null,
  "created_at": "2023-01-19T10:55:43.917Z",
  "updated_at": "2023-01-19T10:55:43.917Z",
  "form_id": 1,
  "position": 1,
  "next_page": null
}
```

### Address

Must select at least one of UK and International address.

#### Both set
Sent from admin:
```json
{
  "question_text": "Address",
  "hint_text": "address hint",
  "answer_type": "address",
  "is_optional": true,
  "answer_settings": {
    "input_type": {
      "uk_address": "true",
      "international_address": "true"
    }
  }
}
```

Returned from API:
```json
{
  "id": 2,
  "question_text": "Address",
  "question_short_name": null,
  "hint_text": "address hint",
  "answer_type": "address",
  "is_optional": true,
  "answer_settings": {
    "input_type": {
      "uk_address": "true",
      "international_address": "true"
    }
  },
  "created_at": "2023-01-19T10:58:31.120Z",
  "updated_at": "2023-01-19T10:58:31.120Z",
  "form_id": 1,
  "position": 2,
  "next_page": null
}
```

#### International_address only
Sent from admin:
```json
{
  "question_text": "International address only",
  "hint_text": "",
  "answer_type": "address",
  "is_optional": null,
  "answer_settings": {
    "input_type": {
      "uk_address": "false",
      "international_address": "true"
    }
  }
}
```

Returned from API:
```json
{
  "id": 17,
  "question_text": "International address only",
  "question_short_name": null,
  "hint_text": "",
  "answer_type": "address",
  "is_optional": null,
  "answer_settings": {
    "input_type": {
      "uk_address": "false",
      "international_address": "true"
    }
  },
  "created_at": "2023-01-19T15:39:45.557Z",
  "updated_at": "2023-01-19T15:39:45.557Z",
  "form_id": 1,
  "position": 17,
  "next_page": null
}
```

#### UK address only
Sent from admin:
```json
{
  "question_text": "uk address only",
  "hint_text": "",
  "answer_type": "address",
  "is_optional": null,
  "answer_settings": {
    "input_type": {
      "uk_address": "true",
      "international_address": "false"
    }
  }
}
```

Returned from API:
```json
{
  "id": 16,
  "question_text": "uk address only",
  "question_short_name": null,
  "hint_text": "",
  "answer_type": "address",
  "is_optional": null,
  "answer_settings": {
    "input_type": {
      "uk_address": "true",
      "international_address": "false"
    }
  },
  "created_at": "2023-01-19T15:37:26.851Z",
  "updated_at": "2023-01-19T15:37:26.851Z",
  "form_id": 1,
  "position": 16,
  "next_page": null
}
```

### Date

#### Without DOB set:
Sent from admin:
```json
{
  "id": 3,
  "question_text": "What is your date of birth?",
  "question_short_name": null,
  "hint_text": "Hint",
  "answer_type": "date",
  "is_optional": null,
  "answer_settings": {
    "input_type": "other_date"
  },
  "next_page": null
}
```

Returned from API:
```json
{
  "id": 3,
  "question_text": "What is your date of birth?",
  "question_short_name": null,
  "hint_text": "Hint",
  "answer_type": "date",
  "is_optional": null,
  "answer_settings": {
    "input_type": "other_date"
  },
  "created_at": "2023-01-19T11:03:08.661Z",
  "updated_at": "2023-01-19T11:17:16.617Z",
  "form_id": 1,
  "position": 3,
  "next_page": null
}
```

#### With date of birth set

Sent from admin:
```json
{
  "question_text": "What is your date of birth?",
  "hint_text": "Hint",
  "answer_type": "date",
  "is_optional": true,
  "answer_settings": {
    "input_type": "date_of_birth"
  }
}
```

Returned from API:
```json
{
  "id": 3,
  "question_text": "What is your date of birth?",
  "question_short_name": null,
  "hint_text": "Hint",
  "answer_type": "date",
  "is_optional": true,
  "answer_settings": {
    "input_type": "date_of_birth"
  },
  "created_at": "2023-01-19T11:03:08.661Z",
  "updated_at": "2023-01-19T11:03:08.661Z",
  "form_id": 1,
  "position": 3,
  "next_page": null
}
```

### Email address
There are no options.

Sent from admin:
```json
{
  "question_text": "Email address",
  "hint_text": "hint",
  "answer_type": "email",
  "is_optional": true,
  "answer_settings": null
}
```

Returned from API:
```json
{
  "id": 4,
  "question_text": "Email address",
  "question_short_name": null,
  "hint_text": "hint",
  "answer_type": "email",
  "is_optional": true,
  "answer_settings": null,
  "created_at": "2023-01-19T11:20:10.557Z",
  "updated_at": "2023-01-19T11:20:10.557Z",
  "form_id": 1,
  "position": 4,
  "next_page": null
}
```

### National Insurance Number
There are no options.

Sent from admin:
```json
{
  "question_text": "National Insurance Number",
  "hint_text": "hint",
  "answer_type": "national_insurance_number",
  "is_optional": true,
  "answer_settings": null
}
```

Returned from API:
```json
{
  "id": 7,
  "question_text": "National Insurance Number",
  "question_short_name": null,
  "hint_text": "hint",
  "answer_type": "national_insurance_number",
  "is_optional": true,
  "answer_settings": null,
  "created_at": "2023-01-19T11:27:50.413Z",
  "updated_at": "2023-01-19T11:27:50.413Z",
  "form_id": 1,
  "position": 7,
  "next_page": null
}
```

### Phone number
There are no options.

Sent from admin:
```json
{
  "question_text": "Phone Number",
  "hint_text": "hint",
  "answer_type": "phone_number",
  "is_optional": true,
  "answer_settings": null
}
```

Returned from API:
```json
{
  "id": 6,
  "question_text": "Phone Number",
  "question_short_name": null,
  "hint_text": "hint",
  "answer_type": "phone_number",
  "is_optional": true,
  "answer_settings": null,
  "created_at": "2023-01-19T11:21:01.023Z",
  "updated_at": "2023-01-19T11:21:01.023Z",
  "form_id": 1,
  "position": 6,
  "next_page": 7
}
```

### Selection Questions
[] People can only select one option
[] Include an option for ‘None of the above’

#### No options set
Sent from admin:
```json
{
  "question_text": "Selection question nothing ticked",
  "hint_text": "hint",
  "answer_type": "selection",
  "is_optional": null,
  "answer_settings": {
    "only_one_option": "0",
    "selection_options": [
      {
        "name": "Option one"
      },
      {
        "name": "Option two"
      },
      {
        "name": "option three"
      }
    ]
  }
}
```

Returned from API:

```json
{
  "id": 8,
  "question_text": "Selection question nothing ticked",
  "question_short_name": null,
  "hint_text": "hint",
  "answer_type": "selection",
  "is_optional": null,
  "answer_settings": {
    "only_one_option": "0",
    "selection_options": [
      {
        "name": "Option one"
      },
      {
        "name": "Option two"
      },
      {
        "name": "option three"
      }
    ]
  },
  "created_at": "2023-01-19T11:30:45.385Z",
  "updated_at": "2023-01-19T11:30:45.385Z",
  "form_id": 1,
  "position": 8,
  "next_page": null
}
```

#### People can only select one option:

Sent from admin:
```json
{
  "id": 8,
  "question_text": "Selection question nothing ticked",
  "question_short_name": null,
  "hint_text": "hint",
  "answer_type": "selection",
  "is_optional": null,
  "answer_settings": {
    "only_one_option": "true",
    "selection_options": [
      {
        "name": "Option one"
      },
      {
        "name": "Option two"
      },
      {
        "name": "option three"
      }
    ]
  },
  "created_at": "2023-01-19T11:30:45.385Z",
  "updated_at": "2023-01-19T11:30:45.385Z",
  "position": 8,
  "next_page": null
}
```

Returned from API:
```json
{
  "id": 8,
  "question_text": "Selection question nothing ticked",
  "question_short_name": null,
  "hint_text": "hint",
  "answer_type": "selection",
  "is_optional": null,
  "answer_settings": {
    "only_one_option": "true",
    "selection_options": [
      {
        "name": "Option one"
      },
      {
        "name": "Option two"
      },
      {
        "name": "option three"
      }
    ]
  },
  "created_at": "2023-01-19T11:30:45.385Z",
  "updated_at": "2023-01-19T11:32:06.490Z",
  "form_id": 1,
  "position": 8,
  "next_page": null
}
```

#### Include an option for ‘None of the above’

Sent from admin:
```json
{
  "id": 8,
  "question_text": "Selection question nothing ticked",
  "question_short_name": null,
  "hint_text": "hint",
  "answer_type": "selection",
  "is_optional": true,
  "answer_settings": {
    "only_one_option": "0",
    "selection_options": [
      {
        "name": "Option one"
      },
      {
        "name": "Option two"
      },
      {
        "name": "option three"
      }
    ]
  },
  "created_at": "2023-01-19T11:30:45.385Z",
  "updated_at": "2023-01-19T11:32:06.490Z",
  "position": 8,
  "next_page": null
}
```

Returned from API:

```json
{
  "id": 8,
  "question_text": "Selection question nothing ticked",
  "question_short_name": null,
  "hint_text": "hint",
  "answer_type": "selection",
  "is_optional": true,
  "answer_settings": {
    "only_one_option": "0",
    "selection_options": [
      {
        "name": "Option one"
      },
      {
        "name": "Option two"
      },
      {
        "name": "option three"
      }
    ]
  },
  "created_at": "2023-01-19T11:30:45.385Z",
  "updated_at": "2023-01-19T11:33:20.209Z",
  "form_id": 1,
  "position": 8,
  "next_page": null
}
```

#### With both included
Sent from admin:
```json
{
  "id": 8,
  "question_text": "Selection question nothing ticked",
  "question_short_name": null,
  "hint_text": "hint",
  "answer_type": "selection",
  "is_optional": true,
  "answer_settings": {
    "only_one_option": "true",
    "selection_options": [
      {
        "name": "Option one"
      },
      {
        "name": "Option two"
      },
      {
        "name": "option three"
      }
    ]
  },
  "created_at": "2023-01-19T11:30:45.385Z",
  "updated_at": "2023-01-19T11:33:20.209Z",
  "position": 8,
  "next_page": null
}
```

Returned from API:
```json
{
  "id": 8,
  "question_text": "Selection question nothing ticked",
  "question_short_name": null,
  "hint_text": "hint",
  "answer_type": "selection",
  "is_optional": true,
  "answer_settings": {
    "only_one_option": "true",
    "selection_options": [
      {
        "name": "Option one"
      },
      {
        "name": "Option two"
      },
      {
        "name": "option three"
      }
    ]
  },
  "created_at": "2023-01-19T11:30:45.385Z",
  "updated_at": "2023-01-19T11:34:37.479Z",
  "form_id": 1,
  "position": 8,
  "next_page": null
}
```

### Company/org name
There are no options.

Sent from admin:
```json
{
  "question_text": "Company org name",
  "hint_text": "hint",
  "answer_type": "organisation_name",
  "is_optional": true,
  "answer_settings": null
}
```

Returned from API:
```json
{
  "id": 9,
  "question_text": "Company org name",
  "question_short_name": null,
  "hint_text": "hint",
  "answer_type": "organisation_name",
  "is_optional": true,
  "answer_settings": null,
  "created_at": "2023-01-19T11:36:59.041Z",
  "updated_at": "2023-01-19T11:36:59.041Z",
  "form_id": 1,
  "position": 9,
  "next_page": null
}
```

### Text
Single line or multiline of text

#### Single line
Sent from admin:
```json
{
  "question_text": "Single line of text",
  "hint_text": "hint",
  "answer_type": "text",
  "is_optional": true,
  "answer_settings": {
    "input_type": "single_line"
  }
}
```

Returned from API:
```json
{
  "id": 10,
  "question_text": "Single line of text",
  "question_short_name": null,
  "hint_text": "hint",
  "answer_type": "text",
  "is_optional": true,
  "answer_settings": {
    "input_type": "single_line"
  },
  "created_at": "2023-01-19T11:38:35.270Z",
  "updated_at": "2023-01-19T11:38:35.270Z",
  "form_id": 1,
  "position": 10,
  "next_page": null
}
```

#### Multline text
Sent from admin:
```json
{
  "question_text": "Multiline of tex",
  "hint_text": "multi line",
  "answer_type": "text",
  "is_optional": true,
  "answer_settings": {
    "input_type": "long_text"
  }
}
```

Returned from API:
```json
{
  "id": 11,
  "question_text": "Multiline of tex",
  "question_short_name": null,
  "hint_text": "multi line",
  "answer_type": "text",
  "is_optional": true,
  "answer_settings": {
    "input_type": "long_text"
  },
  "created_at": "2023-01-19T11:38:52.383Z",
  "updated_at": "2023-01-19T11:38:52.383Z",
  "form_id": 1,
  "position": 11,
  "next_page": null
}
```

## Legacy
The following page types are supported by the runner and may exists in the API DB but can no longer be created using the admin.

### single_line
Sent from admin:
```json
{
  "question_text": "Legacy single line",
  "hint_text": "hint",
  "answer_type": "single_line",
  "is_optional": true
}
```

Returned from API:
```json
{
  "id": 12,
  "question_text": "Legacy single line",
  "question_short_name": null,
  "hint_text": "hint",
  "answer_type": "single_line",
  "is_optional": true,
  "answer_settings": null,
  "created_at": "2023-01-19T13:07:01.843Z",
  "updated_at": "2023-01-19T13:07:01.843Z",
  "form_id": 1,
  "position": 12,
  "next_page": null
}
```

### long_text

Sent from admin:
```json
{
  "question_text": "legacy multi line",
  "hint_text": "hint",
  "answer_type": "long_text",
  "is_optional": null
}
```

Returned from API:
```json
{
  "id": 13,
  "question_text": "legacy multi line",
  "question_short_name": null,
  "hint_text": "hint",
  "answer_type": "long_text",
  "is_optional": null,
  "answer_settings": null,
  "created_at": "2023-01-19T13:09:55.121Z",
  "updated_at": "2023-01-19T13:09:55.121Z",
  "form_id": 1,
  "position": 13,
  "next_page": null
}
```

### address
Sent from admin:
```json
{
  "question_text": "legacy address",
  "hint_text": "address",
  "answer_type": "address",
  "is_optional": null
}
```

Returned from API:
```json
{
  "id": 14,
  "question_text": "legacy address",
  "question_short_name": null,
  "hint_text": "address",
  "answer_type": "address",
  "is_optional": null,
  "answer_settings": null,
  "created_at": "2023-01-19T13:12:01.714Z",
  "updated_at": "2023-01-19T13:12:01.714Z",
  "form_id": 1,
  "position": 14,
  "next_page": null
}
```

### date
Sent from admin:
```json
{
  "question_text": "Legacy Date",
  "hint_text": "hinty",
  "answer_type": "date",
  "is_optional": null
}
```

Returned from API:
```json
{
  "id": 15,
  "question_text": "Legacy Date",
  "question_short_name": null,
  "hint_text": "hinty",
  "answer_type": "date",
  "is_optional": null,
  "answer_settings": null,
  "created_at": "2023-01-19T13:15:09.933Z",
  "updated_at": "2023-01-19T13:15:09.933Z",
  "form_id": 1,
  "position": 15,
  "next_page": null
}
```

## Example of complete form pages array
```json
[
  {
    "id": 1,
    "question_text": "Number question",
    "question_short_name": null,
    "hint_text": "Hint text",
    "answer_type": "number",
    "is_optional": null,
    "answer_settings": null,
    "created_at": "2023-01-19T10:55:43.917Z",
    "updated_at": "2023-01-19T10:55:43.917Z",
    "form_id": 1,
    "position": 1,
    "next_page": 2
  },
  {
    "id": 2,
    "question_text": "Address",
    "question_short_name": null,
    "hint_text": "address hint",
    "answer_type": "address",
    "is_optional": null,
    "answer_settings": {
      "input_type": {
        "uk_address": "true",
        "international_address": "false"
      }
    },
    "created_at": "2023-01-19T10:58:31.120Z",
    "updated_at": "2023-01-19T11:01:04.201Z",
    "form_id": 1,
    "position": 2,
    "next_page": 3
  },
  {
    "id": 3,
    "question_text": "What is your date of birth?",
    "question_short_name": null,
    "hint_text": "Hint",
    "answer_type": "date",
    "is_optional": null,
    "answer_settings": {
      "input_type": "other_date"
    },
    "created_at": "2023-01-19T11:03:08.661Z",
    "updated_at": "2023-01-19T11:17:16.617Z",
    "form_id": 1,
    "position": 3,
    "next_page": 4
  },
  {
    "id": 4,
    "question_text": "Email address",
    "question_short_name": null,
    "hint_text": "hint",
    "answer_type": "email",
    "is_optional": true,
    "answer_settings": null,
    "created_at": "2023-01-19T11:20:10.557Z",
    "updated_at": "2023-01-19T11:20:10.557Z",
    "form_id": 1,
    "position": 4,
    "next_page": 5
  },
  {
    "id": 5,
    "question_text": "National Insurance Number",
    "question_short_name": null,
    "hint_text": "hint",
    "answer_type": "national_insurance_number",
    "is_optional": true,
    "answer_settings": null,
    "created_at": "2023-01-19T11:20:28.119Z",
    "updated_at": "2023-01-19T11:20:28.119Z",
    "form_id": 1,
    "position": 5,
    "next_page": 6
  },
  {
    "id": 6,
    "question_text": "Phone Number",
    "question_short_name": null,
    "hint_text": "hint",
    "answer_type": "phone_number",
    "is_optional": true,
    "answer_settings": null,
    "created_at": "2023-01-19T11:21:01.023Z",
    "updated_at": "2023-01-19T11:21:01.023Z",
    "form_id": 1,
    "position": 6,
    "next_page": 7
  },
  {
    "id": 7,
    "question_text": "National Insurance Number",
    "question_short_name": null,
    "hint_text": "hint",
    "answer_type": "national_insurance_number",
    "is_optional": true,
    "answer_settings": null,
    "created_at": "2023-01-19T11:27:50.413Z",
    "updated_at": "2023-01-19T11:27:50.413Z",
    "form_id": 1,
    "position": 7,
    "next_page": 8
  },
  {
    "id": 8,
    "question_text": "Selection question nothing ticked",
    "question_short_name": null,
    "hint_text": "hint",
    "answer_type": "selection",
    "is_optional": true,
    "answer_settings": {
      "only_one_option": "true",
      "selection_options": [
        {
          "name": "Option one"
        },
        {
          "name": "Option two"
        },
        {
          "name": "option three"
        }
      ]
    },
    "created_at": "2023-01-19T11:30:45.385Z",
    "updated_at": "2023-01-19T11:34:37.479Z",
    "form_id": 1,
    "position": 8,
    "next_page": 9
  },
  {
    "id": 9,
    "question_text": "Company org name",
    "question_short_name": null,
    "hint_text": "hint",
    "answer_type": "organisation_name",
    "is_optional": true,
    "answer_settings": null,
    "created_at": "2023-01-19T11:36:59.041Z",
    "updated_at": "2023-01-19T11:36:59.041Z",
    "form_id": 1,
    "position": 9,
    "next_page": 10
  },
  {
    "id": 10,
    "question_text": "Single line of text",
    "question_short_name": null,
    "hint_text": "hint",
    "answer_type": "text",
    "is_optional": true,
    "answer_settings": {
      "input_type": "single_line"
    },
    "created_at": "2023-01-19T11:38:35.270Z",
    "updated_at": "2023-01-19T11:38:35.270Z",
    "form_id": 1,
    "position": 10,
    "next_page": 11
  },
  {
    "id": 11,
    "question_text": "Multiline of tex",
    "question_short_name": null,
    "hint_text": "multi line",
    "answer_type": "text",
    "is_optional": true,
    "answer_settings": {
      "input_type": "long_text"
    },
    "created_at": "2023-01-19T11:38:52.383Z",
    "updated_at": "2023-01-19T11:38:52.383Z",
    "form_id": 1,
    "position": 11,
    "next_page": null
  }
]
```
