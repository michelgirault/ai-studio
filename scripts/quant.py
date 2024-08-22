from awq import AutoAWQForCausalLM
from transformers import AutoTokenizer
from huggingface_hub import HfApi
api = HfApi()

model_repo_name = 'michelgi/llama3-llava-next-8b-hf-awq' 
model_path = 'llava-hf/llama3-llava-next-8b-hf'
quant_path = 'output/llava-hf/llama3-llava-next-8b-hf-awq'

quant_config = { "zero_point": True, "q_group_size": 128, "w_bit": 4, "version": "GEMM" }

# Load model
model = AutoAWQForCausalLM.from_pretrained(
    model_path, device_map="cuda:0",**{"low_cpu_mem_usage": True}
)
tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)

# Quantize
model.quantize(tokenizer, quant_config=quant_config)

# Save quantized model
model.save_quantized(quant_path)
tokenizer.save_pretrained(quant_path)

print(f'Model is quantized and saved at "{quant_path}"')

#Create Repo in Hugging Face
#api.create_repo(repo_id=model_repo_name)

#Upload Model folder from Local to HuggingFace 
api.upload_folder(
    folder_path=quant_path,
    repo_id=model_repo_name
)

# Publish Model Tokenizer on Hugging Face
tokenizer.push_to_hub(model_repo_name)