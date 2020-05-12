
FUNCTION_NAME := my-function
REGION := us-west-2

GEM_DIR := vendor/bundle

SOURCES := lambda_function.rb vendor
ZIP := function.zip

.PHONY: gems deploy

gems:
	bundle install --path $(GEM_DIR)

$(GEM_DIR):
	$(MAKE) gems

$(ZIP): $(SOURCES) | $(GEM_DIR)
	zip -r $(ZIP) lambda_function.rb vendor

deploy: $(ZIP) | $(GEM_DIR)
	aws lambda update-function-code --function-name $(FUNCTION_NAME) --region $(REGION) --zip-file fileb://$(ZIP)

clean:
	rm -rf $(ZIP) vendor
