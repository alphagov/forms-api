# Page object spec

```
Standard Page {
  answer_type: String
  question_text: String
  hint_text: String?
  is_optional: Boolean?
  id: Integer
  next_page: Integer
}
```

```
Number < StandardPage {
  answer_type: "number"
}
```

```
Email < StandardPage {
  answer_type: "email"
}
```

```
NationalInsuranceNumber < StandardPage {
  answer_type: "national_insurance_number"
}
```

```
PhoneNumber < StandardPage {
  answer_type: "phone_number"
}
```

```
OrganisationName < StandardPage {
  answer_type: "organisation_name"
}
```

```
Address < StandardPage {
  answer_type: "address"
  answer_settings: {
    input_type: {
      uk_address: Boolean
      international_address:  Boolean
  }
}
```

```
Date < StandardPage {
  answer_type: "date"
  answer_settings: {
    input_type: "other_date" | "date_of_birth"
  }
}
```

```
Selection < StandardPage {
  answer_type: "selection"
  answer_settings: {
    only_one_option: Boolean
    selection_options: [
      {
        name: String
      }
    ]
  }
}
```

```
Text < StandardPage {
  answer_type: "text"
  answer_settings: {
    input_type: "single_line" | "long_text"
  }
}
```
