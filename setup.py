from setuptools import setup, find_packages

setup(
    name="glance-minecraft-power",
    version="1.0.0",
    packages=find_packages(),  # Ensure the package is discoverable
    install_requires=["flask"],
    entry_points={
        "console_scripts": [
            "glance-minecraft-power=glance_minecraft_power.main:main",
        ],
    },
)

