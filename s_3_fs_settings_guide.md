# Drupal S3FS Settings Configuration Reference (with Case Examples)

This document provides an in-depth explanation of all configuration options that can be defined in `settings.php` for the Drupal S3 File System (S3FS) module. Each setting includes a real-world use case to clarify when and how it should be used.

---

## 🔐 Authentication

### `$settings['s3fs.access_key']`

**Description:** Specifies your AWS Access Key ID used to authenticate S3 API requests. Required if you're not using IAM roles on EC2 or ECS. **Example:**

```php
$settings['s3fs.access_key'] = 'AKIAIOSFODNN7EXAMPLE';
```

**Use Case:** Hosting your Drupal site on a non-AWS server (e.g., on-prem or DigitalOcean) and needing to manually authenticate with S3.

---

### `$settings['s3fs.secret_key']`

**Description:** AWS Secret Access Key paired with the access key. Ensure this is stored securely. **Example:**

```php
$settings['s3fs.secret_key'] = 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY';
```

**Use Case:** Same as above. Often pulled from environment variables in `settings.local.php` for security.

---

### `$settings['s3fs.region']`

**Description:** AWS region where your bucket is located (e.g., `us-west-2`, `ap-south-1`). **Example:**

```php
$settings['s3fs.region'] = 'ap-south-1';
```

**Use Case:** Ensures correct API endpoints are hit when connecting to S3. Essential when deploying across AWS regions.

---

### `$settings['s3fs.session_token']`

**Description:** Temporary credentials token for IAM role sessions. **Example:**

```php
$settings['s3fs.session_token'] = 'FQoGZXIvYXdz...';
```

**Use Case:** Needed when assuming a role via STS to temporarily access an S3 bucket in secure workflows.

---

## 🪣 Bucket & Paths

### `$config['s3fs.settings']['bucket']`

**Description:** Defines the name of the S3 bucket where files will be stored. **Example:**

```php
$config['s3fs.settings']['bucket'] = 'my-leela-prod-bucket';
```

**Use Case:** A staging site and a production site can point to different buckets using this key.

---

### `$config['s3fs.settings']['root_folder']`

**Description:** Path inside the bucket to be used as the base. Everything stored by S3FS will be prefixed with this. **Example:**

```php
$config['s3fs.settings']['root_folder'] = 'prod/content/assets';
```

**Use Case:** Helps structure files within your bucket. For example, separating dev/stage/prod content in the same bucket.

---

### `$config['s3fs.settings']['public_folder']`

**Description:** Sub-folder inside the root for `public://` files. **Example:**

```php
$config['s3fs.settings']['public_folder'] = 'public';
```

**Use Case:** Keeps public and private files separated logically. CDN or CloudFront can cache only public paths.

---

### `$config['s3fs.settings']['private_folder']`

**Description:** Sub-folder for `private://` files. **Example:**

```php
$config['s3fs.settings']['private_folder'] = 'secure';
```

**Use Case:** Useful in regulated industries where files need restricted access, such as medical documents.

---

### `$config['s3fs.settings']['use_cname']`

**Description:** Enables using a custom domain name (CNAME) for the S3 bucket. **Example:**

```php
$config['s3fs.settings']['use_cname'] = TRUE;
```

**Use Case:** When using a CDN like CloudFront or a vanity domain (e.g., cdn.theleela.com) mapped to your S3 bucket.

---

### `$config['s3fs.settings']['domain']`

**Description:** The domain to use in public URLs if `use_cname` is TRUE. **Example:**

```php
$config['s3fs.settings']['domain'] = 'cdn.theleela.com';
```

**Use Case:** Output URLs like `https://cdn.theleela.com/prod/content/assets/...` instead of the AWS default.

---

## 🖼️ Image Styles and Asset Handling

### `$config['s3fs.settings']['use_s3_for_image_styles']`

**Description:** Whether to store image styles (thumbnails) on S3. **Example:**

```php
$config['s3fs.settings']['use_s3_for_image_styles'] = TRUE;
```

**Use Case:** Reduces disk usage and allows styles to be served via CDN when generated dynamically by Drupal.

---

### `$config['s3fs.settings']['image_style_path']`

**Description:** Directory name used to prefix image style paths. **Example:**

```php
$config['s3fs.settings']['image_style_path'] = 'styles';
```

**Use Case:** Useful for compatibility with Drupal's internal routing like `/styles/tl_large/public/...`

---

### `$config['s3fs.settings']['use_s3_for_public']`

**Description:** Store `public://` stream files on S3 instead of local filesystem. **Example:**

```php
$config['s3fs.settings']['use_s3_for_public'] = TRUE;
```

**Use Case:** Keeps web server stateless; easier to scale and integrate with CDNs.

---

### `$config['s3fs.settings']['use_s3_for_private']`

**Description:** Same as above, but for `private://` stream. **Example:**

```php
$config['s3fs.settings']['use_s3_for_private'] = TRUE;
```

**Use Case:** Useful for multi-site or headless systems needing secured file access via tokenized endpoints.

---

## 🔐 URL & Access Control

### `$config['s3fs.settings']['presigned_urls']`

**Description:** Enable signed URLs with time-limited access to files. **Example:**

```php
$config['s3fs.settings']['presigned_urls'] = TRUE;
```

**Use Case:** For download links that expire after 1 hour, ideal for document access with expiring links.

---

### `$config['s3fs.settings']['use_s3_private_url']`

**Description:** Generates S3-style URLs for `private://` files. **Example:**

```php
$config['s3fs.settings']['use_s3_private_url'] = TRUE;
```

**Use Case:** Ensures links to private files don’t get served directly unless validated or signed.

---

### `$config['s3fs.settings']['signed_url_ttl']`

**Description:** TTL (Time-To-Live) for presigned URLs in seconds. **Example:**

```php
$config['s3fs.settings']['signed_url_ttl'] = 3600; // 1 hour
```

**Use Case:** File downloads that expire in a fixed time window after authentication.

---

### `$config['s3fs.settings']['use_https']`

**Description:** Always use HTTPS links. **Example:**

```php
$config['s3fs.settings']['use_https'] = TRUE;
```

**Use Case:** Enforces secure delivery of assets over SSL; required by modern browsers and SEO.

---

## ⚙️ Performance & Advanced Options

### `$config['s3fs.settings']['cache_control_header']`

**Description:** Cache-Control header applied to file uploads. **Example:**

```php
$config['s3fs.settings']['cache_control_header'] = 'max-age=86400';
```

**Use Case:** Improves CDN edge caching and browser performance.

---

### `$config['s3fs.settings']['custom_host']`

**Description:** Override the host used for S3 URLs. **Example:**

```php
$config['s3fs.settings']['custom_host'] = 'https://assets.theleela.com';
```

**Use Case:** When integrating with an external CDN domain.

---

### `$config['s3fs.settings']['no_preload_path']`

**Description:** Skip pre-creating the S3 folder hierarchy. **Example:**

```php
$config['s3fs.settings']['no_preload_path'] = TRUE;
```

**Use Case:** When using flat structures or reducing write operations during upload.

---

### `$config['s3fs.settings']['root_folder_per_style']`

**Description:** Separate folders per image style. **Example:**

```php
$config['s3fs.settings']['root_folder_per_style'] = FALSE;
```

**Use Case:** Simplifies file lookup if all styles are stored under a single `styles/` folder.

---

## 🧹 Metadata Cache

### `$config['s3fs.settings']['use_cache']`

**Description:** Cache metadata (e.g., file size, existence) locally. **Example:**

```php
$config['s3fs.settings']['use_cache'] = TRUE;
```

**Use Case:** Speeds up site performance and reduces S3 API costs.

---

### `$config['s3fs.settings']['cache_ttl']`

**Description:** Lifetime of metadata cache in seconds. **Example:**

```php
$config['s3fs.settings']['cache_ttl'] = 3600;
```

**Use Case:** Refreshes metadata cache every hour, balancing performance and accuracy.

---

## 🧪 CSS/JS Aggregation

### `$config['s3fs.settings']['no_rewrite_cssjs']`

**Description:** Disable S3 rewriting for aggregated CSS/JS files. **Example:**

```php
$config['s3fs.settings']['no_rewrite_cssjs'] = FALSE;
```

**Use Case:** Useful when local paths are required or a reverse proxy handles asset delivery.

---

Let me know if you'd like to generate this as a Markdown or PDF guide for your dev teams.

