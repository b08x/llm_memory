require 'spec_helper'
require 'llm_memory/broca'

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

  describe 'with Gemini provider' do
    it 'instantiates a new Broca object with Gemini provider' do
      broca = LlmMemory::Broca.new(prompt: 'erb_template', provider: :gemini, model: 'gemini-pro')
      expect(broca).to be_a(LlmMemory::Broca)
      expect(broca.instance_variable_get(:@provider)).to eq(:gemini)
      expect(broca.instance_variable_get(:@model)).to eq('gemini-pro')
    end

    it 'runs respond method with Gemini', :vcr do
      related_docs = [{ content: 'My name is Shohei' }, { content: "I'm a software engineer" }]
      broca = LlmMemory::Broca.new(prompt: template, provider: :gemini, model: 'gemini-pro')

      # Mock the gemini_chat method to avoid actual API calls during testing
      allow(broca).to receive(:gemini_chat).and_return({
                                                         'choices' => [
                                                           {
                                                             'message' => {
                                                               'role' => 'assistant',
                                                               'content' => 'Your name is Shohei.'
                                                             }
                                                           }
                                                         ]
                                                       })

      res = broca.respond(related_docs: related_docs, query_str: 'what is my name?')
      expect(res).to include('Shohei')
    end
  end
end
