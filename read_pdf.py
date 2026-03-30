import subprocess
try:
    from pypdf import PdfReader
except ImportError:
    subprocess.check_call(["pip", "install", "pypdf", "--quiet", "--break-system-packages"])
    from pypdf import PdfReader

reader = PdfReader('/Users/rzengin/Demos/kong-pottencial/docs/Kong - Estratégia de migração - Overview.pdf')
for i, page in enumerate(reader.pages):
    print(page.extract_text())
