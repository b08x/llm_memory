require "spec_helper"
require "llm_memory/broca"

RSpec.describe LlmMemory::Broca do
  template = <<~TEMPLATE
    Context information is below.
    ---------------------
    <% related_docs.each do |doc| %>
    <%= doc[:content] %>
    
    <% end %>
    ---------------------
    Given the context information and not prior knowledge,
    answer the question: <%= query_str %>
  TEMPLATE

  describe ".new" do
    it "instantiates a new Broca object" do
      broca = LlmMemory::Broca.new(prompt: "erb_template")
      expect(broca).to be_a(LlmMemory::Broca)
    end
  end

  describe ".generate_prompt" do
    it "creates prompt with erb" do
      related_docs = [{content: "foo"}, {content: "bar"}]
      broca = LlmMemory::Broca.new(prompt: template)
      prompt = broca.generate_prompt(related_docs: related_docs, query_str: "how are you?")
      expect(prompt).to include("foo")
      expect(prompt).to include("how are you?")
    end
    # Add more test cases as needed
  end
  describe ".generate_prompt" do
    it "runs respond method" do
      related_docs = [{content: "foo"}, {content: "bar"}]
      broca = LlmMemory::Broca.new(prompt: template)
      broca.respond(related_docs: related_docs, query_str: "how are you?")
    end
  end
end
