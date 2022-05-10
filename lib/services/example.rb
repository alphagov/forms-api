class Services::Example
  def execute(example)
    "GOV.UK Forms API: #{example}"
  end

  def get_forms(name)
    JSON({
           name => {
             item2: {
               item3: "ok"
             }
           }
         })
  end
end
