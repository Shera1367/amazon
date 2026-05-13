import streamlit as st
import requests
import re

st.set_page_config(page_title="Amazon Analyzer", layout="centered")
st.title("🔎 تحلیل‌گر محصولات آمازون")

# اطلاعات اختصاصی شما
RAPID_API_KEY = "f850411062msh9c1f1a42f138034p1889e6jsn608a2c1ea3a2"
RAPID_API_HOST = "basic-amazon-scraper.p.rapidapi.com"
AMAZON_SCRAPER_KEY = "f03399e151f471ce4a771f1se2f5yg3d"

def extract_keyword(url):
    # سعی در پیدا کردن کلمه کلیدی از لینک
    match = re.search(r'k=([^&]+)', url)
    if match:
        return match.group(1).replace('+', ' ')
    return "macbook" # مقدار پیش‌فرض برای تست

url_input = st.text_input("لینک آمازون را اینجا وارد کنید:")

if st.button("تحلیل و نمایش نتایج"):
    if url_input:
        with st.spinner('در حال ارتباط با سرور آمازون...'):
            keyword = extract_keyword(url_input)
            api_url = f"https://{RAPID_API_HOST}/search/{keyword}"
            
            headers = {
                "x-rapidapi-key": RAPID_API_KEY,
                "x-rapidapi-host": RAPID_API_HOST
            }
            params = {"api_key": AMAZON_SCRAPER_KEY}

            try:
                response = requests.get(api_url, headers=headers, params=params)
                
                # بررسی اینکه آیا پاسخ معتبر است
                if response.status_code == 200:
                    data = response.json()
                    products = data.get('results', [])
                    
                    if products:
                        # ادامه پردازش ارزان‌ترین و گران‌ترین...
                        valid_items = [p for p in products if p.get('price')]
                        cheapest = min(valid_items, key=lambda x: x['price'])
                        st.success(f"ارزان‌ترین پیدا شد: {cheapest['title']}")
                        st.metric("قیمت", f"${cheapest['price']}")
                    else:
                        st.error("آمازون نتیجه‌ای برنگرداند. کلمات کلیدی در لینک را بررسی کنید.")
                else:
                    st.error(f"خطای سرویس: {response.status_code} - احتمالا اعتبار API تمام شده است.")
            
            except Exception as e:
                st.error(f"خطای فنی: {str(e)}")
